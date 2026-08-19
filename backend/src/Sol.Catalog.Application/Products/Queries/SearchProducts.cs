using FluentValidation;
using Sol.Catalog.Application.Abstractions.Messaging;
using Sol.Catalog.Application.Abstractions.Persistence;
using Sol.Catalog.Application.Common;
using Sol.Catalog.Application.Products.Dtos;
using Sol.Catalog.Domain.Common;
using Sol.Catalog.Domain.Products;

namespace Sol.Catalog.Application.Products.Queries;

public sealed record SearchProductsQuery(
    string? Q = null,
    int Page = 1,
    int PageSize = SearchProductsQuery.DefaultPageSize,
    ProductSortField SortBy = ProductSortField.Name,
    SortDirection SortDir = SortDirection.Asc,
    decimal? MinPrice = null,
    decimal? MaxPrice = null,
    string? Currency = null,
    bool InStock = false) : IQuery<PagedResult<ProductResponse>>
{
    public const int DefaultPageSize = 20;

    public const int MaxPageSize = 100;
}

internal sealed class SearchProductsQueryValidator : AbstractValidator<SearchProductsQuery>
{
    public SearchProductsQueryValidator()
    {
        RuleFor(q => q.Page)
            .GreaterThan(0)
            .WithMessage("La página debe ser mayor a 0.");

        RuleFor(q => q.PageSize)
            .InclusiveBetween(1, SearchProductsQuery.MaxPageSize)
            .WithMessage($"El tamaño de página debe estar entre 1 y {SearchProductsQuery.MaxPageSize}.");

        RuleFor(q => q.Q)
            .MaximumLength(Product.NameMaxLength)
            .WithMessage($"El texto de búsqueda no puede superar los {Product.NameMaxLength} caracteres.");

        RuleFor(q => q.MinPrice)
            .GreaterThan(0)
            .When(q => q.MinPrice.HasValue)
            .WithMessage("El precio mínimo debe ser mayor a 0.");

        RuleFor(q => q.MaxPrice)
            .GreaterThan(0)
            .When(q => q.MaxPrice.HasValue)
            .WithMessage("El precio máximo debe ser mayor a 0.");

        RuleFor(q => q.MaxPrice)
            .GreaterThanOrEqualTo(q => q.MinPrice!.Value)
            .When(q => q.MinPrice.HasValue && q.MaxPrice.HasValue)
            .WithMessage("El precio máximo no puede ser menor que el mínimo.");

        RuleFor(q => q.Currency)
            .Length(Money.CurrencyLength)
            .When(q => !string.IsNullOrWhiteSpace(q.Currency))
            .WithMessage("La moneda debe ser un código de tres letras.");
    }
}

internal sealed class SearchProductsQueryHandler(IProductReader reader)
    : IQueryHandler<SearchProductsQuery, PagedResult<ProductResponse>>
{
    public async Task<Result<PagedResult<ProductResponse>>> HandleAsync(
        SearchProductsQuery query,
        CancellationToken cancellationToken)
    {
        var spec = new ProductQuerySpec(
            SearchTerm: string.IsNullOrWhiteSpace(query.Q) ? null : query.Q.Trim(),
            Page: query.Page,
            PageSize: query.PageSize,
            SortBy: query.SortBy,
            SortDirection: query.SortDir,
            MinPrice: query.MinPrice,
            MaxPrice: query.MaxPrice,
            Currency: string.IsNullOrWhiteSpace(query.Currency)
                ? null
                : query.Currency.Trim().ToUpperInvariant(),
            OnlyInStock: query.InStock);

        PagedResult<Product> page = await reader
            .SearchAsync(spec, cancellationToken)
            .ConfigureAwait(false);

        return Result.Success(page.Map(p => p.ToResponse()));
    }
}
