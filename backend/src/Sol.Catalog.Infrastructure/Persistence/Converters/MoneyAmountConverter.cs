using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace Sol.Catalog.Infrastructure.Persistence.Converters;

internal sealed class MoneyAmountConverter : ValueConverter<decimal, long>
{
    private const decimal Scale = 100m;

    public MoneyAmountConverter()
        : base(
            amount => (long)Math.Round(amount * Scale, MidpointRounding.AwayFromZero),
            minorUnits => minorUnits / Scale)
    {
    }
}
