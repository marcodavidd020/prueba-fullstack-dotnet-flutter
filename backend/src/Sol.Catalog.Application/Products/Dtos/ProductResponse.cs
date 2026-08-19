using System.ComponentModel;
using System.Globalization;
using Sol.Catalog.Domain.Products;

namespace Sol.Catalog.Application.Products.Dtos;

public sealed record ProductResponse(
    int Id,
    string Sku,
    string Name,
    string Price,
    string Currency,
    int Stock,
    DateTimeOffset UpdatedAt,
    int Version);

public sealed record UpdatePriceRequest(
    [property: Description("Nuevo importe, como cadena decimal con punto. Por ejemplo \"249.90\".")]
    string? Price,

    [property: Description("Código ISO 4217 de tres letras. Por ejemplo BOB o USD.")]
    string? Currency);

public static class ProductMappings
{
    private const string PriceFormat = "0.00";

    public static ProductResponse ToResponse(this Product product)
    {
        ArgumentNullException.ThrowIfNull(product);

        return new ProductResponse(
            product.Id,
            product.Sku.Value,
            product.Name,
            product.Price.Amount.ToString(PriceFormat, CultureInfo.InvariantCulture),
            product.Price.Currency,
            product.Stock,
            product.UpdatedAt,
            product.Version);
    }
}
