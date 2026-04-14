<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Questionnaire extends Model
{
    protected $guarded = ['id'];

    protected $casts = [
        'data_json' => 'array',
        'localite_id' => 'integer',
    ];

    /**
     * Relation : le questionnaire appartient à un utilisateur.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Scope : filtrer par type de formulaire.
     */
    public function scopeOfType($query, string $type)
    {
        return $query->where('type', $type);
    }

    /**
     * Scope : filtrer par utilisateur.
     */
    public function scopeForUser($query, int $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope : filtrer par localité.
     */
    public function scopeForLocalite($query, ?int $localiteId)
    {
        if ($localiteId === null) {
            return $query->whereNull('localite_id');
        }
        return $query->where('localite_id', $localiteId);
    }
}
