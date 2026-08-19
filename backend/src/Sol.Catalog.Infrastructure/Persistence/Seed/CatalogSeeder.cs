using System.Globalization;
using System.Reflection;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Sol.Catalog.Domain.Common;
using Sol.Catalog.Domain.Products;

namespace Sol.Catalog.Infrastructure.Persistence.Seed;

public static class CatalogSeeder
{
    private const string EmbeddedResourceName = "Sol.Catalog.Infrastructure.Persistence.Seed.products.json";

    private static readonly JsonSerializerOptions SerializerOptions = new()
    {
        PropertyNameCaseInsensitive = true,
    };

    public static async Task SeedAsync(
        CatalogDbContext db,
        TimeProvider timeProvider,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(db);
        ArgumentNullException.ThrowIfNull(timeProvider);

        if (await db.Products.AnyAsync(cancellationToken).ConfigureAwait(false))
        {
            return;
        }

        DateTimeOffset now = timeProvider.GetUtcNow();
        IEnumerable<Product> products = ReadFile().Select(row => Build(row, now));

        db.Products.AddRange(products);
        await db.SaveChangesAsync(cancellationToken).ConfigureAwait(false);
    }

    private static IReadOnlyList<SeedRow> ReadFile()
    {
        using Stream stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(EmbeddedResourceName)
            ?? throw new InvalidOperationException(
                $"No se encontró el recurso embebido '{EmbeddedResourceName}'. "
                + "Verificá que products.json esté declarado como EmbeddedResource en el .csproj.");

        SeedFile? file = JsonSerializer.Deserialize<SeedFile>(stream, SerializerOptions);

        return file?.Products
            ?? throw new InvalidOperationException("El archivo semilla no contiene productos.");
    }

    private static Product Build(SeedRow row, DateTimeOffset now)
    {
        Result<Sku> sku = Sku.Create(row.Sku);
        if (sku.IsFailure)
        {
            throw new InvalidOperationException(
                $"Semilla inválida en SKU '{row.Sku}': {sku.Error.Description}");
        }

        if (!decimal.TryParse(
                row.Price,
                NumberStyles.AllowDecimalPoint,
                CultureInfo.InvariantCulture,
                out decimal amount))
        {
            throw new InvalidOperationException(
                $"Semilla inválida en SKU '{row.Sku}': el precio '{row.Price}' no es un decimal con punto.");
        }

        Result<Money> price = Money.Create(amount, row.Currency);
        if (price.IsFailure)
        {
            throw new InvalidOperationException(
                $"Semilla inválida en SKU '{row.Sku}': {price.Error.Description}");
        }

        Result<Product> product = Product.Create(sku.Value, row.Name, price.Value, row.Stock, now);
        if (product.IsFailure)
        {
            throw new InvalidOperationException(
                $"Semilla inválida en SKU '{row.Sku}': {product.Error.Description}");
        }

        return product.Value;
    }

    private sealed record SeedFile(IReadOnlyList<SeedRow>? Products);

    private sealed record SeedRow(string? Sku, string? Name, string? Price, string? Currency, int Stock);
}
