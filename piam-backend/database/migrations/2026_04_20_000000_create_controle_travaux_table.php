<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (Schema::hasTable('controle_travaux')) {
            return;
        }

        Schema::create('controle_travaux', function (Blueprint $blueprint) {
            $blueprint->id();
            $blueprint->foreignId('user_id')->constrained()->onDelete('cascade');
            $blueprint->integer('localite_id')->nullable();
            
            // Niveau 1 - Données générales
            $blueprint->string('site_selectionne')->nullable();
            $blueprint->string('etablissement')->nullable();
            $blueprint->string('nature_travaux')->nullable();
            $blueprint->string('niveau_ecole')->nullable();
            $blueprint->string('type_structure')->nullable();
            
            // Niveau 2 - Organisation Chantier
            $blueprint->string('nom_entreprise')->nullable();
            $blueprint->string('numero_marche')->nullable();
            $blueprint->text('intitule_projet')->nullable();
            $blueprint->date('date_demarrage')->nullable();
            $blueprint->string('delai_marche')->nullable();
            $blueprint->string('chef_chantier')->nullable();
            $blueprint->string('bureau_controle')->nullable();
            $blueprint->integer('effectif_encadrement')->nullable();
            $blueprint->integer('effectif_ouvrier')->nullable();
            $blueprint->integer('effectif_total')->nullable();
            
            // Niveau 2 - Sécurité (EPC/EPI)
            $blueprint->string('casques')->nullable();
            $blueprint->string('gilets')->nullable();
            $blueprint->string('masques')->nullable();
            $blueprint->string('chaussures')->nullable();
            $blueprint->string('gants')->nullable();
            $blueprint->string('premier_secours')->nullable();
            
            // Niveau 3 - Contrôle technique (Statuts simplifiés)
            $blueprint->json('section_status')->nullable();
            $blueprint->text('appreciation_avancement')->nullable();
            $blueprint->text('recommandations_principales')->nullable();
            
            // Niveau 4 - Réception
            $blueprint->date('date_reception_provisoire')->nullable();
            $blueprint->date('date_reception_definitive')->nullable();
            $blueprint->string('avis_reception')->nullable();
            
            // Métadonnées
            $blueprint->json('data_json')->nullable();
            $blueprint->string('sync_status')->default('synced');
            $blueprint->timestamps();

            // Un seul enregistrement par localité et par utilisateur pour le suivi
            $blueprint->unique(['user_id', 'localite_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('controle_travaux');
    }
};
