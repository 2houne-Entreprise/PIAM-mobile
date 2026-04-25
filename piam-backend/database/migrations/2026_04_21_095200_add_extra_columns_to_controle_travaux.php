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
            if (!Schema::hasColumn('controle_travaux', 'date_reception_technique')) {
                $table->date('date_reception_technique')->nullable();
            }
            if (!Schema::hasColumn('controle_travaux', 'date_demarrage_chantier')) {
                $table->date('date_demarrage_chantier')->nullable();
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('controle_travaux', function (Blueprint $table) {
            $table->dropColumn(['date_reception_technique', 'date_demarrage_chantier']);
        });
    }
};
