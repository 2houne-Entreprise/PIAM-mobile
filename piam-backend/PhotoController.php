<?php

namespace App\Http\Controllers;

use App\Models\Photo;
use Illuminate\Http\Request;

class PhotoController extends Controller
{
    public function index() { return Photo::all(); }
    public function store(Request $request) { return Photo::create($request->all()); }
    public function show($id) { return Photo::findOrFail($id); }
    public function update(Request $request, $id) {
        $photo = Photo::findOrFail($id);
        $photo->update($request->all());
        return $photo;
    }
    public function destroy($id) { Photo::destroy($id); return response()->json(['message'=>'Photo deleted']); }
}
