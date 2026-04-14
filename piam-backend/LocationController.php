<?php

namespace App\Http\Controllers;

use App\Models\Location;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    public function index() { return Location::all(); }
    public function store(Request $request) { return Location::create($request->all()); }
    public function show($id) { return Location::findOrFail($id); }
    public function update(Request $request, $id) {
        $location = Location::findOrFail($id);
        $location->update($request->all());
        return $location;
    }
    public function destroy($id) { Location::destroy($id); return response()->json(['message'=>'Location deleted']); }
}
