<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Code de vérification</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
            line-height: 1.6;
        }
        .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: 600;
        }
        .header p {
            margin: 10px 0 0 0;
            opacity: 0.9;
            font-size: 16px;
        }
        .content {
            padding: 40px 30px;
            text-align: center;
        }
        .content h2 {
            color: #333;
            margin-bottom: 20px;
            font-size: 24px;
        }
        .content p {
            color: #666;
            font-size: 16px;
            margin-bottom: 20px;
        }
        .verification-code {
            font-size: 36px;
            font-weight: bold;
            color: #667eea;
            letter-spacing: 8px;
            margin: 30px 0;
            padding: 25px;
            border: 3px dashed #667eea;
            border-radius: 12px;
            background: linear-gradient(135deg, #f8f9ff 0%, #e8ecff 100%);
            display: inline-block;
            min-width: 200px;
        }
        .warning {
            background: linear-gradient(135deg, #fff3cd 0%, #ffeaa7 100%);
            color: #856404;
            padding: 20px;
            border-radius: 8px;
            margin: 30px 0;
            border-left: 4px solid #ffc107;
            text-align: left;
        }
        .warning strong {
            display: block;
            margin-bottom: 10px;
            font-size: 16px;
        }
        .warning ul {
            margin: 10px 0;
            padding-left: 20px;
        }
        .warning li {
            margin-bottom: 5px;
        }
        .footer {
            background-color: #f8f9fa;
            padding: 25px;
            text-align: center;
            font-size: 14px;
            color: #6c757d;
            border-top: 1px solid #e9ecef;
        }
        .icon {
            font-size: 48px;
            margin-bottom: 15px;
        }
        .btn {
            display: inline-block;
            padding: 12px 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 600;
            margin-top: 20px;
            transition: transform 0.2s;
        }
        .btn:hover {
            transform: translateY(-2px);
        }
    </style>
</head>
<body>
    <div class="email-container">
        <div class="header">
            <div class="icon">🔐</div>
            <h1>Code de Vérification</h1>
            <p>Vérifiez votre adresse email pour finaliser votre inscription</p>
        </div>
        
        <div class="content">
            <h2>Bonjour !</h2>
            <p>Vous êtes presque arrivé(e) au bout ! Voici votre code de vérification à 6 chiffres :</p>
            
            <div class="verification-code">
                {{ $code }}
            </div>
            
            <p><strong>Entrez ce code dans l'application pour continuer votre inscription.</strong></p>
            
            <div class="warning">
                <strong>⚠️ Informations importantes :</strong>
                <ul>
                    <li>Ce code expire dans <strong>10 minutes</strong></li>
                    <li>Ne partagez <strong>jamais</strong> ce code avec personne</li>
                    <li>Notre équipe ne vous demandera jamais ce code par téléphone ou email</li>
                    <li>Si vous n'avez pas demandé ce code, ignorez cet email</li>
                </ul>
            </div>
            
            <p style="margin-top: 30px; color: #999; font-size: 14px;">
                Vous rencontrez des problèmes ? Contactez notre support technique.
            </p>
        </div>
        
        <div class="footer">
            <p><strong>Cet email a été envoyé automatiquement, merci de ne pas répondre.</strong></p>
            <p>&copy; {{ date('Y') }} Votre Application. Tous droits réservés.</p>
            <p style="margin-top: 15px; font-size: 12px; opacity: 0.7;">
                Si vous n'arrivez pas à voir ce code correctement, voici le code en texte : <strong>{{ $code }}</strong>
            </p>
        </div>
    </div>
</body>
</html>