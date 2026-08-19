using System.Globalization;
using Sol.Catalog.Domain.Common;

namespace Sol.Catalog.Domain.Products;

public sealed record Money
{
    public const int CurrencyLength = 3;

    private Money(decimal amount, string currency)
    {
        Amount = amount;
        Currency = currency;
    }

    public decimal Amount { get; }

    public string Currency { get; }

    public static Result<Money> Create(decimal amount, string? currency)
    {
        if (amount <= 0)
        {
            return Result.Failure<Money>(ProductErrors.PriceMustBePositive);
        }

        if (string.IsNullOrWhiteSpace(currency))
        {
            return Result.Failure<Money>(ProductErrors.InvalidCurrency);
        }

        var normalizada = currency.Trim().ToUpperInvariant();

        if (normalizada.Length != CurrencyLength || !normalizada.All(char.IsAsciiLetterUpper))
        {
            return Result.Failure<Money>(ProductErrors.InvalidCurrency);
        }

        return Result.Success(new Money(amount, normalizada));
    }

    public override string ToString() =>
        string.Create(CultureInfo.InvariantCulture, $"{Amount:0.00} {Currency}");
}
