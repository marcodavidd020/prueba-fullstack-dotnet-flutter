using System.Text.RegularExpressions;
using Sol.Catalog.Domain.Common;

namespace Sol.Catalog.Domain.Products;

public sealed partial record Sku
{
    public const int MinLength = 3;

    public const int MaxLength = 32;

    private Sku(string value) => Value = value;

    public string Value { get; }

    public static Result<Sku> Create(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return Result.Failure<Sku>(ProductErrors.SkuRequired);
        }

        var normalizado = value.Trim().ToUpperInvariant();

        return Formato().IsMatch(normalizado)
            ? Result.Success(new Sku(normalizado))
            : Result.Failure<Sku>(ProductErrors.InvalidSku);
    }

    public override string ToString() => Value;

    [GeneratedRegex(
        @"^[A-Z0-9][A-Z0-9\-]{1,30}[A-Z0-9]$",
        RegexOptions.CultureInvariant,
        matchTimeoutMilliseconds: 200)]
    private static partial Regex Formato();
}
