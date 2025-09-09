<?php

namespace App\Notifications;

use App\Models\Quote;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Messages\DatabaseMessage;
use Illuminate\Notifications\Notification;

class QuotePublishedNotification extends Notification implements ShouldQueue
{
    use Queueable;

    protected $quote;

    /**
     * Create a new notification instance.
     */
    public function __construct(Quote $quote)
    {
        $this->quote = $quote;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['database', 'mail']; // Vous pouvez ajouter 'broadcast' pour les notifications en temps réel
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
                    ->subject('Nouvelle citation publiée')
                    ->greeting('Bonjour !')
                    ->line('Une nouvelle citation a été publiée :')
                    ->line('"' . $this->quote->text . '"')
                    ->line('— ' . $this->quote->author)
                    ->action('Voir toutes les citations', url('/quotes'))
                    ->line('Merci de nous suivre !');
    }

    /**
     * Get the database representation of the notification.
     */
    public function toDatabase(object $notifiable): array
    {
        return [
            'quote_id' => $this->quote->id,
            'message' => 'Nouvelle citation publiée',
            'quote_text' => $this->quote->text,
            'quote_author' => $this->quote->author,
            'published_at' => $this->quote->updated_at,
        ];
    }

    /**
     * Get the broadcastable representation of the notification (optionnel, pour les notifications en temps réel).
     */
    public function toBroadcast(object $notifiable): array
    {
        return [
            'quote_id' => $this->quote->id,
            'message' => 'Nouvelle citation publiée : "' . $this->quote->text . '" — ' . $this->quote->author,
            'quote_text' => $this->quote->text,
            'quote_author' => $this->quote->author,
        ];
    }

    /**
     * Get the array representation of the notification.
     */
    public function toArray(object $notifiable): array
    {
        return [
            'quote_id' => $this->quote->id,
            'message' => 'Nouvelle citation publiée',
            'quote_text' => $this->quote->text,
            'quote_author' => $this->quote->author,
        ];
    }
}