<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Table questionnaires — correspond au format SQLite Flutter.
     * Chaque questionnaire est identifié par (type, localite_id, user_id).
     */
    public function up(): void
    {
        Schema::create('questionnaires', function (Blueprint $table) {
            $table->id();
            $table->string('type');                           // 'declenchement', 'certification_fdal', etc.
            $table->json('data_json');                        // Données du formulaire en JSON
            $table->unsignedBigInteger('user_id');
            $table->integer('localite_id')->nullable();
            $table->string('sync_status')->default('synced'); // 'synced', 'modified'
            $table->string('photo_path')->nullable();
            $table->timestamps();                             // created_at, updated_at

            // Un seul questionnaire par type + localité + utilisateur
            $table->unique(['type', 'localite_id', 'user_id'], 'questionnaire_unique');

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->index(['user_id', 'type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('questionnaires');
    }
};
