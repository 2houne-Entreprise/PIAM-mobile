<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ControleTravaux extends Model
{
    protected $table = 'controle_travaux';
    
    protected $guarded = ['id'];

    protected $casts = [
        'data_json' => 'array',
        'localite_id' => 'integer',
        'section_status' => 'array',
    ];

    /**
     * Relation : appartient à un utilisateur.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
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
