using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace Sol.Catalog.Api.Middleware;

internal sealed partial class GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger) : IExceptionHandler
{
    [LoggerMessage(
        EventId = 1000,
        Level = LogLevel.Error,
        Message = "Excepción no controlada en {Method} {Path}. TraceId: {TraceId}")]
    private static partial void LogUnhandled(
        ILogger logger,
        Exception exception,
        string method,
        string path,
        string traceId);

    public async ValueTask<bool> TryHandleAsync(
        HttpContext httpContext,
        Exception exception,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(httpContext);

        LogUnhandled(
            logger,
            exception,
            httpContext.Request.Method,
            httpContext.Request.Path,
            httpContext.TraceIdentifier);

        var problem = new ProblemDetails
        {
            Status = StatusCodes.Status500InternalServerError,
            Title = "Ocurrió un error procesando la solicitud",
            Detail = "Si el problema persiste, reportá el identificador de seguimiento.",
            Instance = httpContext.Request.Path,
        };

        problem.Extensions["traceId"] = httpContext.TraceIdentifier;

        httpContext.Response.StatusCode = problem.Status.Value;
        await httpContext.Response
            .WriteAsJsonAsync(problem, cancellationToken)
            .ConfigureAwait(false);

        return true;
    }
}
