using System.Reflection;
using Microsoft.Extensions.DependencyInjection.Extensions;

namespace Sol.Catalog.Api.Endpoints;

public interface IEndpoint
{
    void MapEndpoint(IEndpointRouteBuilder app);
}

public static class EndpointExtensions
{
    public static IServiceCollection AddEndpoints(this IServiceCollection services)
    {
        ArgumentNullException.ThrowIfNull(services);

        IEnumerable<ServiceDescriptor> descriptors = Assembly.GetExecutingAssembly()
            .DefinedTypes
            .Where(t => t is { IsAbstract: false, IsInterface: false }
                        && t.IsAssignableTo(typeof(IEndpoint)))
            .Select(t => ServiceDescriptor.Transient(typeof(IEndpoint), t));

        services.TryAddEnumerable(descriptors);

        return services;
    }

    public static IApplicationBuilder MapEndpoints(this WebApplication app, RouteGroupBuilder? group = null)
    {
        ArgumentNullException.ThrowIfNull(app);

        IEndpointRouteBuilder target = group is null ? app : group;

        foreach (IEndpoint endpoint in app.Services.GetRequiredService<IEnumerable<IEndpoint>>())
        {
            endpoint.MapEndpoint(target);
        }

        return app;
    }
}
