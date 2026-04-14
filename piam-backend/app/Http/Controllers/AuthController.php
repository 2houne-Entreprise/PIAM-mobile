<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class AuthController extends Controller
{
    /**
     * Login : authentification par email + password.
     * POST /api/login
     *
     * Retourne un token Sanctum + les données utilisateur.
     */
    public function login(Request $request): JsonResponse
    {
        $request->validate([
            'email'    => 'required|string|email',
            'password' => 'required|string|min:6',
        ]);

        // Vérifier les identifiants
        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'message' => 'Email ou mot de passe incorrect',
            ], 401);
        }

        $user = Auth::user();

        // Supprimer les anciens tokens (optionnel : limite à 1 session)
        $user->tokens()->delete();

        // Créer un nouveau token Sanctum
        $token = $user->createToken('piam-mobile-token')->plainTextToken;

        return response()->json([
            'message' => 'Connexion réussie',
            'token'   => $token,
            'user'    => [
                'id'       => $user->id,
                'name'     => $user->name,
                'email'    => $user->email,
                'role'     => $user->role ?? 'collecteur',
                'created_at' => $user->created_at,
            ],
        ]);
    }

    /**
     * Logout : révoquer le token courant.
     * POST /api/logout
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Déconnexion réussie',
        ]);
    }

    /**
     * Profil : récupérer les informations de l'utilisateur connecté.
     * GET /api/user
     */
    public function user(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'id'       => $user->id,
            'name'     => $user->name,
            'email'    => $user->email,
            'role'     => $user->role ?? 'collecteur',
            'created_at' => $user->created_at,
        ]);
    }
}
