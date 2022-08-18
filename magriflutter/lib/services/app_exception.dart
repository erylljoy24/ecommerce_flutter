class ApiException {
  final String? message;
  final String? prefix;
  final String? url;
  ApiException([this.message, this.prefix, this.url]);
}

class BadRequestException extends ApiException {
  BadRequestException([String? message, String? prefix, String? url])
      : super(message, 'Bad Request', url);
}

class FetchDataException extends ApiException {
  FetchDataException([String? message, String? prefix, String? url])
      : super(message, 'FetchDataException', url);
}

class NotFoundException extends ApiException {
  NotFoundException([String? message, String? prefix, String? url])
      : super(message, 'NotFoundException', url);
}

class SiteMaintenanceException extends ApiException {
  SiteMaintenanceException([String? message, String? prefix, String? url])
      : super(message, 'SiteMaintenanceException', url);
}

class ApiNotRespondingException extends ApiException {
  ApiNotRespondingException([String? message, String? prefix, String? url])
      : super(message, 'ApiNotRespondingException', url);
}

class UnAuthorizedException extends ApiException {
  UnAuthorizedException([String? message, String? prefix, String? url])
      : super(message, 'UnAuthorizedException', url);
}
