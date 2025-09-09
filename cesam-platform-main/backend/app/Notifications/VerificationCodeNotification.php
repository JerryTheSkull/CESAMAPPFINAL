<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class VerificationCodeNotification extends Notification implements ShouldQueue
{
    use Queueable;

    private $verificationCode;
    private $userName;

    /**
     * Create a new notification instance.
     */
    public function __construct($verificationCode, $userName)
    {
        $this->verificationCode = $verificationCode;
        $this->userName = $userName;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Code de vérification - Inscription CESAM')
            ->greeting('Bonjour ' . $this->userName . ' !')
            ->line('Merci de vous être inscrit sur notre plateforme.')
            ->line('Voici votre code de vérification pour finaliser votre inscription :')
            ->line('**Code : ' . $this->verificationCode . '**')
            ->line('Ce code expire dans 10 minutes.')
            ->line('Si vous n\'avez pas demandé cette inscription, ignorez cet email.')
            ->salutation('Cordialement, L\'équipe CESAM');
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'verification_code' => $this->verificationCode,
            'user_name' => $this->userName,
        ];
    }
}