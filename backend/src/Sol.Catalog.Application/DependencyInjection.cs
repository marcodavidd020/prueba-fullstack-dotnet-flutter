using FluentValidation;
using Microsoft.Extensions.DependencyInjection;
using Sol.Catalog.Application.Abstractions.Messaging;
using Sol.Catalog.Application.Behaviors;
using Sol.Catalog.Application.Common;
using Sol.Catalog.Application.Products.Commands;
using Sol.Catalog.Application.Products.Dtos;
using Sol.Catalog.Application.Products.Queries;

namespace Sol.Catalog.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        ArgumentNullException.ThrowIfNull(services);

        services.AddValidatorsFromAssemblyContaining<AssemblyMarker>(includeInternalTypes: true);

        services.TryAddSingletonTimeProvider();

        services.AddQuery<SearchProductsQuery, PagedResult<ProductResponse>, SearchProductsQueryHandler>();
        services.AddQuery<GetProductByIdQuery, ProductResponse, GetProductByIdQueryHandler>();
        services.AddCommand<UpdateProductPriceCommand, ProductResponse, UpdateProductPriceCommandHandler>();

        return services;
    }

    private static void TryAddSingletonTimeProvider(this IServiceCollection services)
    {
        if (!services.Any(d => d.ServiceType == typeof(TimeProvider)))
        {
            services.AddSingleton(TimeProvider.System);
        }
    }

    private static void AddQuery<TQuery, TResult, THandler>(this IServiceCollection services)
        where TQuery : IQuery<TResult>
        where THandler : class, IQueryHandler<TQuery, TResult>
    {
        services.AddScoped<THandler>();
        services.AddScoped<IQueryHandler<TQuery, TResult>>(sp =>
            new ValidationQueryDecorator<TQuery, TResult>(
                sp.GetRequiredService<THandler>(),
                sp.GetService<IValidator<TQuery>>()));
    }

    private static void AddCommand<TCommand, TResult, THandler>(this IServiceCollection services)
        where TCommand : ICommand<TResult>
        where THandler : class, ICommandHandler<TCommand, TResult>
    {
        services.AddScoped<THandler>();
        services.AddScoped<ICommandHandler<TCommand, TResult>>(sp =>
            new ValidationCommandDecorator<TCommand, TResult>(
                sp.GetRequiredService<THandler>(),
                sp.GetService<IValidator<TCommand>>()));
    }
}
