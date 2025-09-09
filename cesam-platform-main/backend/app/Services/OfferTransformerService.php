<?php

namespace App\Services;

use App\Models\Offer;

class OfferTransformerService
{
    /**
     * Transformer une seule offre pour l'API
     */
    public static function transform(Offer $offer): array
    {
        return [
            'id' => $offer->id,
            'title' => $offer->title,
            'type' => $offer->type,
            'description' => $offer->description,
            'images' => $offer->images ?? [],
            'pdfs' => $offer->pdfs ?? [],
            'links' => $offer->links ?? [],
            'is_active' => $offer->is_active,
            'published_at' => $offer->published_at?->format('Y-m-d H:i:s'),
            'applications_count' => $offer->applications()->count(),
            'created_at' => $offer->created_at?->format('Y-m-d H:i:s'),
            'updated_at' => $offer->updated_at?->format('Y-m-d H:i:s'),
        ];
    }

    /**
     * Transformer une collection d'offres pour l'API
     */
    public static function transformCollection($offers): array
    {
        return collect($offers)->map(function ($offer) {
            return self::transform($offer);
        })->toArray();
    }
}
