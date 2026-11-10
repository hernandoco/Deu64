class AuthConfig {
  static const String clientId =
      //'44ro8e7dgavbohj7419e82tgj0'; 23 sep 2026 Hernando: se cambia por el valor generado en AWS Cognito
      '79svdmo6ic9rnvpnqk84n60ub5'; // El dia 23 se configuraron los nuevos valores, pero houy 25 al entrar a aws con el suaurios de IA se devolvieron los valores
      
      // Callback 
  static const String redirectUri =
//      'com.miempresa.miapp://oauth/callback';
      //'https://d84l1y8p4kdic.cloudfront.net'; 23 sep 2026 Hernando: se cambia porque debe trener el mismo valor que en AWS
      'deu64://oauth2redirect';
    
  static const String cognitoDomain =
      //'https://us-east-2_RlzSOWfNF.auth.us-east-2.amazoncognito.com'; //23 sept 2026 Hernando: Se adiciona por valor generado en AWS Cognito
      'https://us-east-2rlzsowfnf.auth.us-east-2.amazoncognito.com'; //25 sep 2026 Hernando: en aws en Domain apare en mininsucuras


  static const String userPoolId =
      'us-east-2_RlzSOWfNF';

  static const String logoutRedirectUri =
      //'com.miempresa.miapp://oauth/logout';
      //'https://d84l1y8p4kdic.cloudfront.net'; 23 sep 2026 Hernando: se cambia porque debe trener el mismo valor que en AWS
      //'deu64://oauth2redirect'; 
      'deu64://logout'; // 25 sep 2026 Hernando: lo cambio. en AWS tiene est e valor en el Allowe sign-out URLASs

// Campo con nombre en AWS como [OpenID Connect configurations URL]
  static const String discoveryUrl =
      //'https://miapp.auth.us-east-1.amazoncognito.com/'
      //'.well-known/openid-configuration';
      //'https://us-east-14rxws9kug.auth.us-east-1.amazoncognito.com' // 23 sep 2026 Hernando: se cambia por el nuevo valor Chat GPT & AWS
      //'.well-known/openid-configuration';
           'https://cognito-idp.us-east-2.amazonaws.com/'
           '$userPoolId/.well-known/openid-configuration';

  static const List<String> scopes = [
    'openid',
    //'profile',// Lo mas sencillo posible
    'email',
    'phone',
  ];
}
