namespace Sol.Catalog.Application.Common;

public sealed record PagedResult<T>(
    IReadOnlyList<T> Items,
    int Page,
    int PageSize,
    int Total)
{
    public int TotalPages => PageSize <= 0
        ? 0
        : (int)Math.Ceiling(Total / (double)PageSize);

    public bool HasNext => Page < TotalPages;

    public bool HasPrevious => Page > 1 && Total > 0;

    public PagedResult<TOut> Map<TOut>(Func<T, TOut> selector)
    {
        ArgumentNullException.ThrowIfNull(selector);
        return new PagedResult<TOut>([.. Items.Select(selector)], Page, PageSize, Total);
    }
}

public static class PagedResult
{
    public static PagedResult<T> Empty<T>(int page, int pageSize) => new([], page, pageSize, 0);
}
