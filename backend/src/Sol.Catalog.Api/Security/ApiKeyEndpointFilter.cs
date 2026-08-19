using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace Sol.Catalog.Api.Security;

public sealed class ApiKeyOptions
{
    public const string SectionName = "Security";

    public const string HeaderName = "X-Api-Key";

    public string? ApiKey { get; init; }
}

internal sealed class ApiKeyEndpointFilter(IOptions<ApiKeyOptions> options) : IEndpointFilter
{
    public async ValueTask<object?> InvokeAsync(
        EndpointFilterInvocationContext context,
        EndpointFilterDelegate next)
    {
        ArgumentNullException.ThrowIfNull(context);
        ArgumentNullException.ThrowIfNull(next);

        string? expected = options.Value.ApiKey;

        if (string.IsNullOrWhiteSpace(expected))
        {
            return await next(context).ConfigureAwait(false);
        }

        string received = context.HttpContext.Request.Headers[ApiKeyOptions.HeaderName].ToString();

        if (!string.Equals(received, expected, StringComparison.Ordinal))
        {
            return TypedResults.Problem(new ProblemDetails
            {
                Status = StatusCodes.Status401Unauthorized,
                Title = "Falta la clave de API o no es válida",
                Detail = $"Enviá la cabecera {ApiKeyOptions.HeaderName}.",
            });
        }

        return await next(context).ConfigureAwait(false);
    }
}
