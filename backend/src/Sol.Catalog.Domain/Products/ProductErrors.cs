using Sol.Catalog.Domain.Common;

namespace Sol.Catalog.Domain.Products;

public static class ProductErrors
{
    public static readonly Error PriceMustBePositive = Error.Validation(
        "Product.PriceMustBePositive",
        "El precio debe ser mayor a 0.");

    public static readonly Error InvalidPriceFormat = Error.Validation(
        "Product.InvalidPriceFormat",
        "El precio debe ser un número decimal con punto, por ejemplo 249.90.");

    public static readonly Error InvalidCurrency = Error.Validation(
        "Product.InvalidCurrency",
        "La moneda es obligatoria y debe ser un código de tres letras (por ejemplo BOB o USD).");

    public static readonly Error SkuRequired = Error.Validation(
        "Product.SkuRequired",
        "El SKU es obligatorio.");

    public static readonly Error InvalidSku = Error.Validation(
        "Product.InvalidSku",
        "El SKU debe tener entre 3 y 32 caracteres y contener solo letras, números y guiones.");

    public static readonly Error NameRequired = Error.Validation(
        "Product.NameRequired",
        "El nombre del producto es obligatorio.");

    public static readonly Error NameTooLong = Error.Validation(
        "Product.NameTooLong",
        $"El nombre no puede superar los {Product.NameMaxLength} caracteres.");

    public static readonly Error StockCannotBeNegative = Error.Validation(
        "Product.StockCannotBeNegative",
        "El stock no puede ser negativo.");

    public static readonly Error ConcurrencyConflict = Error.Conflict(
        "Product.ConcurrencyConflict",
        "El producto fue modificado por otra persona. Recargá para ver el estado actual.");

    public static readonly Error PreconditionFailed = new(
        "Product.PreconditionFailed",
        "La versión del producto que tenés no es la actual. Recargá antes de guardar.",
        ErrorType.PreconditionFailed);

    public static Error NotFound(int id) => Error.NotFound(
        "Product.NotFound",
        $"No existe un producto con id {id}.");
}
