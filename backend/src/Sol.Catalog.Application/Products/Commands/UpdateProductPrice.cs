using System.Globalization;
using FluentValidation;
using Sol.Catalog.Application.Abstractions.Messaging;
using Sol.Catalog.Application.Abstractions.Persistence;
using Sol.Catalog.Application.Products.Dtos;
using Sol.Catalog.Domain.Common;
using Sol.Catalog.Domain.Products;

namespace Sol.Catalog.Application.Products.Commands;

public sealed record UpdateProductPriceCommand(
    int Id,
    string? Price,
    string? Currency,
    int? ExpectedVersion = null) : ICommand<ProductResponse>;

internal sealed class UpdateProductPriceCommandValidator : AbstractValidator<UpdateProductPriceCommand>
{
    public UpdateProductPriceCommandValidator()
    {
        RuleFor(c => c.Id)
            .GreaterThan(0)
            .WithMessage("El identificador debe ser mayor a 0.");

        RuleFor(c => c.Price)
            .Cascade(CascadeMode.Stop)
            .NotEmpty()
            .WithMessage("El precio es obligatorio.")
            .Must(ParsesAsDecimal)
            .WithMessage("El precio debe ser un número decimal con punto, por ejemplo 249.90.");

        RuleFor(c => c.Currency)
            .Cascade(CascadeMode.Stop)
            .NotEmpty()
            .WithMessage("La moneda es obligatoria.")
            .Length(Money.CurrencyLength)
            .WithMessage("La moneda debe ser un código de tres letras, por ejemplo BOB.");
    }

    internal static bool TryParsePrice(string? value, out decimal price) =>
        decimal.TryParse(
            value,
            NumberStyles.AllowDecimalPoint | NumberStyles.AllowLeadingSign,
            CultureInfo.InvariantCulture,
            out price);

    private static bool ParsesAsDecimal(string? value) => TryParsePrice(value, out _);
}

internal sealed class UpdateProductPriceCommandHandler(
    IProductReader reader,
    IProductWriter writer,
    IUnitOfWork unitOfWork,
    TimeProvider timeProvider)
    : ICommandHandler<UpdateProductPriceCommand, ProductResponse>
{
    public async Task<Result<ProductResponse>> HandleAsync(
        UpdateProductPriceCommand command,
        CancellationToken cancellationToken)
    {
        Product? product = await reader
            .GetByIdAsync(command.Id, cancellationToken)
            .ConfigureAwait(false);

        if (product is null)
        {
            return Result.Failure<ProductResponse>(ProductErrors.NotFound(command.Id));
        }

        if (command.ExpectedVersion is { } expectedVersion && expectedVersion != product.Version)
        {
            return Result.Failure<ProductResponse>(ProductErrors.PreconditionFailed);
        }

        if (!UpdateProductPriceCommandValidator.TryParsePrice(command.Price, out decimal amount))
        {
            return Result.Failure<ProductResponse>(ProductErrors.InvalidPriceFormat);
        }

        Result<Money> price = Money.Create(amount, command.Currency);

        if (price.IsFailure)
        {
            return Result.Failure<ProductResponse>(price.Error);
        }

        Result change = product.ChangePrice(price.Value, timeProvider.GetUtcNow());

        if (change.IsFailure)
        {
            return Result.Failure<ProductResponse>(change.Error);
        }

        writer.Update(product);

        Result saved = await unitOfWork.SaveChangesAsync(cancellationToken).ConfigureAwait(false);

        return saved.IsFailure
            ? Result.Failure<ProductResponse>(saved.Error)
            : Result.Success(product.ToResponse());
    }
}
