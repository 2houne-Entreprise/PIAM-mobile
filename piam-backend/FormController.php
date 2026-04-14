<?php

namespace App\Http\Controllers;

use App\Models\Form;
use Illuminate\Http\Request;

class FormController extends Controller
{
    // Liste des formulaires
    public function index()
    {
        return Form::all();
    }

    // Créer un formulaire
    public function store(Request $request)
    {
        $form = Form::create($request->all());
        return response()->json($form, 201);
    }

    // Afficher un formulaire
    public function show($id)
    {
        return Form::findOrFail($id);
    }

    // Mise à jour (sauvegarde auto)
    public function update(Request $request, $id)
    {
        $form = Form::findOrFail($id);
        $form->update($request->all());
        return response()->json($form);
    }

    // Supprimer un formulaire
    public function destroy($id)
    {
        Form::destroy($id);
        return response()->json(['message' => 'Form deleted']);
    }

    // Dashboard : compteurs par statut
    public function dashboardStats()
    {
        $stats = Form::selectRaw('status, COUNT(*) as count')->groupBy('status')->get();
        return response()->json($stats);
    }
}
