library constants;

final String appUsed = 'appUsed';

// For API endpoints
// const GOOGLE_MAPS_API_KEY = 'AIzaSyBvYIn85W4Z7AW2QyUsDLB81v0RNufoHC8';
const GOOGLE_MAPS_API_KEY = 'AIzaSyCCgaVlDWys8gyYOxfTJUwpM3zIoMQfQ24';

// Pusher
const PUSHER_APP_KEY = '6fafd80ee270a8412b67';
const PUSHER_CLUSTER = 'ap1';
const PUSHER_ENCRYPTED = true;

// final String base = "https://magriapp.site/api/v1";

// Live
final String base = "https://backoffice.magriapp.site/api/v1";

// Sandbox
// final String base = "https://sandbox.magri.com.ph/api/v1";

const HAS_SAMPLE_ACCOUNT = false;
const DEBUG_SHOW_MODE_BANNER = true;

// expose share https://magri.test --subdomain=magri

final String loginToken = base + '/login/token';
final String loginGuest = base + '/login/guest';

final String categories = base + '/categories';

final String banners = base + '/banners';

final String postProduct = base + '/products';

final String getProducts = base + '/products';

final String getInbox = base + '/inbox';

final String postEvents = base + '/events';

final String getEvents = base + '/events';

final String favoriteProduct = base + '/products';

final String apiVerify = base + '/verify';

final String passwordResetEmail = base + '/password/reset';

final String login = base + '/login';
final String signup = base + '/signup';

final String passwordResetCode = base + '/password/reset/code';
final String passwordUpdate = base + '/password/update';
