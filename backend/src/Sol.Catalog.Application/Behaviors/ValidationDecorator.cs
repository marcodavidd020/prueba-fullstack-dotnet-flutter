using FluentValidation;
using FluentValidation.Results;
using Sol.Catalog.Application.Abstractions.Messaging;
using Sol.Catalog.Application.Common;
using Sol.Catalog.Domain.Common;

namespace Sol.Catalog.Application.Behaviors;

internal sealed class ValidationQueryDecorator<TQuery, TResult>(
    IQueryHandler<TQuery, TResult> inner,
    IValidator<TQuery>? validator = null)
    : IQueryHandler<TQuery, TResult>
    where TQuery : IQuery<TResult>
{
    public async Task<Result<TResult>> HandleAsync(TQuery query, CancellationToken cancellationToken)
    {
        if (validator is null)
        {
            return await inner.HandleAsync(query, cancellationToken).ConfigureAwait(false);
        }

        ValidationResult validation = await validator
            .ValidateAsync(query, cancellationToken)
            .ConfigureAwait(false);

        return validation.IsValid
            ? await inner.HandleAsync(query, cancellationToken).ConfigureAwait(false)
            : Result.Failure<TResult>(ValidationError.From(validation));
    }
}

internal sealed class ValidationCommandDecorator<TCommand, TResult>(
    ICommandHandler<TCommand, TResult> inner,
    IValidator<TCommand>? validator = null)
    : ICommandHandler<TCommand, TResult>
    where TCommand : ICommand<TResult>
{
    public async Task<Result<TResult>> HandleAsync(TCommand command, CancellationToken cancellationToken)
    {
        if (validator is null)
        {
            return await inner.HandleAsync(command, cancellationToken).ConfigureAwait(false);
        }

        ValidationResult validation = await validator
            .ValidateAsync(command, cancellationToken)
            .ConfigureAwait(false);

        return validation.IsValid
            ? await inner.HandleAsync(command, cancellationToken).ConfigureAwait(false)
            : Result.Failure<TResult>(ValidationError.From(validation));
    }
}
