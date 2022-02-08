class ThreeDModel {
  ThreeDModel({
    required this.id,
    required this.title,
    required this.adlibID,
    required this.image,
    required this.glb
  });

   final int id;
   final String title;
   final String adlibID;
   final String image;
   final String glb;


  factory ThreeDModel.fromJson(Map<String, dynamic> data) {
    return ThreeDModel(
        id: data['data'][0]['id'],
        title: data['data'][0]['title'],
        adlibID: data['data'][0]['adlib_id'],
        image: data['data'][0]['thumbnail']['data']['thumbnails'][2]['url'],
        glb: data['data'][0]["glb_file"]['data']['full_url']
    );
  }
}
