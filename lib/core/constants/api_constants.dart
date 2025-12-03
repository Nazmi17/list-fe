class ApiConstants {
  static const String baseUrl = "http://localhost/api";

  //auth
  static const String register = "/auth/register";
  static const String login = "/auth/login";

  //user
  static String user(int id) => "/users/$id"; 

  //task
  static const String tasks = "/tasks";
  static String task(int id) => "/tasks/$id";

  //folder
 static const String folders = "/folders";
  static String folder(int id) => "/folders/$id";
  static String folderTasks(int id) => "/folders/$id/tasks";
  static String folderShare(int id) => "/folders/$id/share";
  static String folderUnshare(int userid, int folderId) =>
      "/folders/$folderId/share/$userid";
  static const String searchUsers = "/folders/search-users";
  static String folderLeave(int id) => "/folders/$id/leave";

  //header
  static const String contentType = "application/json";
  static const String authorization = "Authorization";
  static const String bearer = "Bearer";
}
