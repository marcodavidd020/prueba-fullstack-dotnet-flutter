using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Sol.Catalog.Domain.Products;
using Sol.Catalog.Infrastructure.Persistence.Converters;

namespace Sol.Catalog.Infrastructure.Persistence.Configurations;

internal sealed class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    public const string SearchTextProperty = "SearchText";

    public void Configure(EntityTypeBuilder<Product> builder)
    {
        ArgumentNullException.ThrowIfNull(builder);

        builder.ToTable("Products");
        builder.HasKey(p => p.Id);

        builder.Property(p => p.Id).ValueGeneratedOnAdd();

        builder.ComplexProperty(p => p.Sku, sku =>
        {
            sku.Property(s => s.Value)
               .HasColumnName("Sku")
               .HasMaxLength(Sku.MaxLength)
               .IsRequired();
        });

        builder.Property(p => p.Name)
               .HasMaxLength(Product.NameMaxLength)
               .IsRequired();

        builder.ComplexProperty(p => p.Price, price =>
        {
            price.Property(m => m.Amount)
                 .HasColumnName("PriceAmount")
                 .HasConversion<MoneyAmountConverter>()
                 .IsRequired();

            price.Property(m => m.Currency)
                 .HasColumnName("Currency")
                 .HasMaxLength(Money.CurrencyLength)
                 .IsRequired();
        });

        builder.Property<string>(SearchTextProperty)
               .HasMaxLength(Product.NameMaxLength + Sku.MaxLength + 1)
               .IsRequired();

        builder.Property(p => p.Stock).IsRequired();
        builder.Property(p => p.UpdatedAt).IsRequired();

        builder.Property(p => p.Version)
               .IsConcurrencyToken()
               .IsRequired();

        builder.HasIndex(p => p.Name).HasDatabaseName("IX_Products_Name");
    }
}
