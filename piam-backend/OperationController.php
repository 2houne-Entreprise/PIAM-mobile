<?php

namespace App\Http\Controllers;

use App\Models\Operation;
use Illuminate\Http\Request;

class OperationController extends Controller
{
    public function index() { return Operation::all(); }
    public function store(Request $request) { return Operation::create($request->all()); }
    public function show($id) { return Operation::findOrFail($id); }
    public function update(Request $request, $id) {
        $operation = Operation::findOrFail($id);
        $operation->update($request->all());
        return $operation;
    }
    public function destroy($id) { Operation::destroy($id); return response()->json(['message'=>'Operation deleted']); }
}
