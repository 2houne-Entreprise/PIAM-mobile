<?php

namespace App\Http\Controllers;

use App\Models\Response;
use Illuminate\Http\Request;

class ResponseController extends Controller
{
    public function index() { return Response::all(); }
    public function store(Request $request) { return Response::create($request->all()); }
    public function show($id) { return Response::findOrFail($id); }
    public function update(Request $request, $id) {
        $response = Response::findOrFail($id);
        $response->update($request->all());
        return $response;
    }
    public function destroy($id) { Response::destroy($id); return response()->json(['message'=>'Response deleted']); }
}
