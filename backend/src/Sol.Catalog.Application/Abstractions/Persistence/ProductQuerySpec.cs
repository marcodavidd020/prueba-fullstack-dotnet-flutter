namespace Sol.Catalog.Application.Abstractions.Persistence;

public enum ProductSortField
{
    Name = 0,
    Price = 1,
    Stock = 2,
    Sku = 3,
}

public enum SortDirection
{
    Asc = 0,
    Desc = 1,
}

public sealed record ProductQuerySpec(
    string? SearchTerm,
    int Page,
    int PageSize,
    ProductSortField SortBy,
    SortDirection SortDirection,
    decimal? MinPrice,
    decimal? MaxPrice,
    string? Currency,
    bool OnlyInStock);
