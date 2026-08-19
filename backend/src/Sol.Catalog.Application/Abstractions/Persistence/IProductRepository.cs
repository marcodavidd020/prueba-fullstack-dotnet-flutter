using Sol.Catalog.Application.Common;
using Sol.Catalog.Domain.Common;
using Sol.Catalog.Domain.Products;

namespace Sol.Catalog.Application.Abstractions.Persistence;

public interface IProductReader
{
    Task<PagedResult<Product>> SearchAsync(ProductQuerySpec spec, CancellationToken cancellationToken);

    Task<Product?> GetByIdAsync(int id, CancellationToken cancellationToken);
}

public interface IProductWriter
{
    void Update(Product product);
}

public interface IUnitOfWork
{
    Task<Result> SaveChangesAsync(CancellationToken cancellationToken);
}
