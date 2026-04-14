<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\QuestionnaireController;

/*
|--------------------------------------------------------------------------
| API Routes — PIAM Mobile
|--------------------------------------------------------------------------
|
| Routes protégées par Sanctum pour l'application mobile PIAM.
| Base URL: /api
|
*/

// ── Routes publiques (pas d'auth requise) ───────────────────────────────────
Route::post('/login', [AuthController::class, 'login']);

// ── Routes protégées (auth:sanctum) ─────────────────────────────────────────
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    // Questionnaires (CRUD)
    Route::get('/questionnaires', [QuestionnaireController::class, 'index']);
    Route::post('/questionnaires', [QuestionnaireController::class, 'store']);
    Route::get('/questionnaires/{id}', [QuestionnaireController::class, 'show']);
    Route::put('/questionnaires/{id}', [QuestionnaireController::class, 'update']);
    Route::delete('/questionnaires/{id}', [QuestionnaireController::class, 'destroy']);

    // Synchronisation en batch
    Route::post('/questionnaires/sync-batch', [QuestionnaireController::class, 'syncBatch']);

    // Dashboard
    Route::get('/dashboard-stats', [QuestionnaireController::class, 'dashboardStats']);
});
