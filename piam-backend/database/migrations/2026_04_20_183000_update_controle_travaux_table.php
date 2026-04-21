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
        Schema::table('controle_travaux', function (Blueprint $table) {
            // Check if columns exist before adding them to avoid errors
            if (!Schema::hasColumn('controle_travaux', 'site_selectionne')) {
                $table->string('site_selectionne')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'etablissement')) {
                $table->string('etablissement')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'nature_travaux')) {
                $table->string('nature_travaux')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'niveau_ecole')) {
                $table->string('niveau_ecole')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'type_structure')) {
                $table->string('type_structure')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'nom_entreprise')) {
                $table->string('nom_entreprise')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'numero_marche')) {
                $table->string('numero_marche')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'intitule_projet')) {
                $table->text('intitule_projet')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'date_demarrage')) {
                $table->date('date_demarrage')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'delai_marche')) {
                $table->string('delai_marche')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'chef_chantier')) {
                $table->string('chef_chantier')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'bureau_controle')) {
                $table->string('bureau_controle')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'effectif_encadrement')) {
                $table->integer('effectif_encadrement')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'effectif_ouvrier')) {
                $table->integer('effectif_ouvrier')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'effectif_total')) {
                $table->integer('effectif_total')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'casques')) {
                $table->string('casques')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'gilets')) {
                $table->string('gilets')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'masques')) {
                $table->string('masques')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'chaussures')) {
                $table->string('chaussures')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'gants')) {
                $table->string('gants')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'premier_secours')) {
                $table->string('premier_secours')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'section_status')) {
                $table->json('section_status')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'appreciation_avancement')) {
                $table->text('appreciation_avancement')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'recommandations_principales')) {
                $table->text('recommandations_principales')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'date_reception_provisoire')) {
                $table->date('date_reception_provisoire')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'date_reception_definitive')) {
                $table->date('date_reception_definitive')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'avis_reception')) {
                $table->string('avis_reception')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'sync_status')) {
                $table->string('sync_status')->default('synced');
            }
            if (!Schema::hasColumn('controle_travaux', 'data_json')) {
                $table->json('data_json')->nullable();
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('controle_travaux', function (Blueprint $table) {
            // No drop in down to avoid data loss on standard rollback
        });
    }
};
