<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\FormController;

// Auth routes
Route::post('/login', [AuthController::class, 'login']);
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);

    // Formulaires
    Route::get('/forms', [FormController::class, 'index']);
    Route::post('/forms', [FormController::class, 'store']);
    Route::get('/forms/{id}', [FormController::class, 'show']);
    Route::put('/forms/{id}', [FormController::class, 'update']);
    Route::delete('/forms/{id}', [FormController::class, 'destroy']);
    Route::get('/dashboard-stats', [FormController::class, 'dashboardStats']);

    // Utilisateurs
    Route::get('/users', [UserController::class, 'index']);
    Route::post('/users', [UserController::class, 'store']);
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::put('/users/{id}', [UserController::class, 'update']);
    Route::delete('/users/{id}', [UserController::class, 'destroy']);

    // Locations
    Route::get('/locations', [LocationController::class, 'index']);
    Route::post('/locations', [LocationController::class, 'store']);
    Route::get('/locations/{id}', [LocationController::class, 'show']);
    Route::put('/locations/{id}', [LocationController::class, 'update']);
    Route::delete('/locations/{id}', [LocationController::class, 'destroy']);

    // Operations
    Route::get('/operations', [OperationController::class, 'index']);
    Route::post('/operations', [OperationController::class, 'store']);
    Route::get('/operations/{id}', [OperationController::class, 'show']);
    Route::put('/operations/{id}', [OperationController::class, 'update']);
    Route::delete('/operations/{id}', [OperationController::class, 'destroy']);

    // Responses
    Route::get('/responses', [ResponseController::class, 'index']);
    Route::post('/responses', [ResponseController::class, 'store']);
    Route::get('/responses/{id}', [ResponseController::class, 'show']);
    Route::put('/responses/{id}', [ResponseController::class, 'update']);
    Route::delete('/responses/{id}', [ResponseController::class, 'destroy']);

    // Photos
    Route::get('/photos', [PhotoController::class, 'index']);
    Route::post('/photos', [PhotoController::class, 'store']);
    Route::get('/photos/{id}', [PhotoController::class, 'show']);
    Route::put('/photos/{id}', [PhotoController::class, 'update']);
    Route::delete('/photos/{id}', [PhotoController::class, 'destroy']);
});
