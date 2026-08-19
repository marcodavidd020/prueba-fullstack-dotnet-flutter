namespace Sol.Catalog.Domain.Common;

public enum ErrorType
{
    Failure = 0,
    Validation = 1,
    NotFound = 2,
    Conflict = 3,
    PreconditionFailed = 4,
}
