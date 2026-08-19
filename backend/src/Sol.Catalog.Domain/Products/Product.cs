using Sol.Catalog.Domain.Common;

namespace Sol.Catalog.Domain.Products;

public sealed class Product
{
    public const int NameMaxLength = 200;

    private Product()
    {
        Sku = null!;
        Name = null!;
        Price = null!;
    }

    private Product(
        int id,
        Sku sku,
        string name,
        Money price,
        int stock,
        DateTimeOffset updatedAt,
        int version)
    {
        Id = id;
        Sku = sku;
        Name = name;
        Price = price;
        Stock = stock;
        UpdatedAt = updatedAt;
        Version = version;
    }

    public int Id { get; private set; }

    public Sku Sku { get; private set; }

    public string Name { get; private set; }

    public Money Price { get; private set; }

    public int Stock { get; private set; }

    public DateTimeOffset UpdatedAt { get; private set; }

    public int Version { get; private set; }

    public static Result<Product> Create(
        Sku sku,
        string? name,
        Money price,
        int stock,
        DateTimeOffset now,
        int id = 0)
    {
        ArgumentNullException.ThrowIfNull(sku);
        ArgumentNullException.ThrowIfNull(price);

        if (string.IsNullOrWhiteSpace(name))
        {
            return Result.Failure<Product>(ProductErrors.NameRequired);
        }

        string normalizedName = name.Trim();

        if (normalizedName.Length > NameMaxLength)
        {
            return Result.Failure<Product>(ProductErrors.NameTooLong);
        }

        if (stock < 0)
        {
            return Result.Failure<Product>(ProductErrors.StockCannotBeNegative);
        }

        return Result.Success(
            new Product(id, sku, normalizedName, price, stock, now, version: 1));
    }

    public Result ChangePrice(Money newPrice, DateTimeOffset now)
    {
        ArgumentNullException.ThrowIfNull(newPrice);

        if (newPrice == Price)
        {
            return Result.Success();
        }

        Price = newPrice;
        UpdatedAt = now;
        Version++;

        return Result.Success();
    }
}
