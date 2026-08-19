using FluentValidation;
using Sol.Catalog.Application.Abstractions.Messaging;
using Sol.Catalog.Application.Abstractions.Persistence;
using Sol.Catalog.Application.Products.Dtos;
using Sol.Catalog.Domain.Common;
using Sol.Catalog.Domain.Products;

namespace Sol.Catalog.Application.Products.Queries;

public sealed record GetProductByIdQuery(int Id) : IQuery<ProductResponse>;

internal sealed class GetProductByIdQueryValidator : AbstractValidator<GetProductByIdQuery>
{
    public GetProductByIdQueryValidator() =>
        RuleFor(q => q.Id)
            .GreaterThan(0)
            .WithMessage("El identificador debe ser mayor a 0.");
}

internal sealed class GetProductByIdQueryHandler(IProductReader reader)
    : IQueryHandler<GetProductByIdQuery, ProductResponse>
{
    public async Task<Result<ProductResponse>> HandleAsync(
        GetProductByIdQuery query,
        CancellationToken cancellationToken)
    {
        Product? product = await reader
            .GetByIdAsync(query.Id, cancellationToken)
            .ConfigureAwait(false);

        return product is null
            ? Result.Failure<ProductResponse>(ProductErrors.NotFound(query.Id))
            : Result.Success(product.ToResponse());
    }
}
