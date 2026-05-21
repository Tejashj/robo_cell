import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedPage extends StatefulWidget {

  final Map<String, dynamic> user;

  const FeedPage({
    super.key,
    required this.user,
  });

  @override
  State<FeedPage> createState() =>
      _FeedPageState();
}

class _FeedPageState
    extends State<FeedPage> {

  final supabase =
      Supabase.instance.client;

  bool loading = true;

  bool posting = false;

  List<Map<String, dynamic>>
      posts = [];

  final titleController =
      TextEditingController();

  final contentController =
      TextEditingController();

  @override
  void initState() {

    super.initState();

    loadPosts();
  }

  bool canPost() {

    final role =
        widget.user['role'];

    return role ==
            'president' ||

        role ==
            'vice_president' ||

        role ==
            'secretary' ||

        role ==
            'treasurer' ||

        role ==
            'head' ||

        role ==
            'co_head';
  }

  Future<void> loadPosts() async {

    try {

      final data =
          await supabase

              .from('posts')

              .select('''
                *,
                users(
                  name,
                  role,
                  photo_url
                )
              ''')

              .order(
                'created_at',
                ascending: false,
              );

      posts =
          List<Map<String, dynamic>>
              .from(data);

    } catch (e) {

      debugPrint(e.toString());
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> createPost()
  async {

    if (titleController.text
            .trim()
            .isEmpty ||

        contentController.text
            .trim()
            .isEmpty) {

      return;
    }

    setState(() {
      posting = true;
    });

    try {

      await supabase

          .from('posts')

          .insert({

        'creator_id':
            widget.user['id'],

        'title':
            titleController.text
                .trim(),

        'content':
            contentController.text
                .trim(),
      });

      titleController.clear();

      contentController.clear();

      await loadPosts();

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(
          content:
              Text("Post Published"),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(
          content:
              Text(e.toString()),
        ),
      );
    }

    setState(() {
      posting = false;
    });
  }

  Widget sectionTitle(
    String title,
  ) {

    return Padding(

      padding:
          const EdgeInsets.only(
        bottom: 16,
      ),

      child: Row(

        children: [

          Container(

            width: 4,

            height: 18,

            decoration:
                BoxDecoration(

              color:
                  const Color(
                0xFF16A085,
              ),

              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Text(

            title,

            style:
                const TextStyle(

              color:
                  Color(
                0xFFD8CFB4,
              ),

              fontSize: 15,

              fontWeight:
                  FontWeight.bold,

              letterSpacing:
                  1,
            ),
          ),
        ],
      ),
    );
  }

  Widget input({

    required String hint,

    required TextEditingController
        controller,

    int maxLines = 1,
  }) {

    return TextField(

      controller: controller,

      maxLines: maxLines,

      style:
          const TextStyle(
        color: Colors.white,
      ),

      decoration:
          InputDecoration(

        hintText: hint,

        hintStyle:
            const TextStyle(
          color: Colors.grey,
        ),

        filled: true,

        fillColor:
            Colors.white
                .withOpacity(0.03),

        border:
            OutlineInputBorder(

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }

  Widget postCard(
    Map<String, dynamic> post,
  ) {

    final creator =
        post['users'];

    final photo =
        creator['photo_url'];

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 18,
      ),

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          BoxDecoration(

        color:
            Colors.white
                .withOpacity(0.03),

        borderRadius:
            BorderRadius.circular(
          22,
        ),

        border: Border.all(
          color: Colors.white10,
        ),
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment
                .start,

        children: [

          Row(

            children: [

              CircleAvatar(

                radius: 24,

                backgroundColor:
                    const Color(
                  0xFF16A085,
                ),

                child: CircleAvatar(

                  radius: 22,

                  backgroundColor:
                      Colors.black,

                  backgroundImage:
                      photo != null &&
                              photo != ''
                          ? NetworkImage(
                              photo,
                            )
                          : null,

                  child:
                      photo == null ||
                              photo == ''
                          ? const Icon(

                              Icons.person,

                              color:
                                  Color(
                                0xFF16A085,
                              ),
                            )
                          : null,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    Text(

                      creator['name'],

                      style:
                          const TextStyle(

                        color:
                            Color(
                          0xFFD8CFB4,
                        ),

                        fontWeight:
                            FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(

                      creator['role']
                          .toString()
                          .replaceAll(
                            '_',
                            ' ',
                          )
                          .toUpperCase(),

                      style:
                          const TextStyle(

                        color:
                            Color(
                          0xFF16A085,
                        ),

                        fontSize: 10,

                        letterSpacing:
                            1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 18,
          ),

          Text(

            post['title'],

            style:
                const TextStyle(

              color:
                  Color(
                0xFFD8CFB4,
              ),

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Text(

            post['content'],

            style:
                const TextStyle(

              color:
                  Colors.white70,

              fontSize: 14,

              height: 1.6,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          Row(

            children: [

              const Icon(

                Icons.access_time_rounded,

                size: 16,

                color:
                    Colors.grey,
              ),

              const SizedBox(width: 6),

              Text(

                post['created_at']
                    .toString()
                    .substring(0, 16)
                    .replaceAll(
                      'T',
                      ' • ',
                    ),

                style:
                    const TextStyle(

                  color:
                      Colors.grey,

                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      body:
          loading

              ? const Center(

                  child:
                      CircularProgressIndicator(
                    color:
                        Color(
                      0xFF16A085,
                    ),
                  ),
                )

              : RefreshIndicator(

                  color:
                      const Color(
                    0xFF16A085,
                  ),

                  onRefresh:
                      loadPosts,

                  child:
                      SingleChildScrollView(

                    physics:
                        const AlwaysScrollableScrollPhysics(),

                    padding:
                        const EdgeInsets.all(
                      18,
                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        /// CREATE POST
                        if (canPost())

                          Container(

                            padding:
                                const EdgeInsets.all(
                              20,
                            ),

                            decoration:
                                BoxDecoration(

                              color: Colors
                                  .white
                                  .withOpacity(
                                0.03,
                              ),

                              borderRadius:
                                  BorderRadius.circular(
                                24,
                              ),

                              border: Border.all(
                                color:
                                    Colors.white10,
                              ),
                            ),

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                sectionTitle(
                                  "CREATE POST",
                                ),

                                input(

                                  hint:
                                      "Post Title",

                                  controller:
                                      titleController,
                                ),

                                const SizedBox(
                                  height: 14,
                                ),

                                input(

                                  hint:
                                      "Write announcement or update...",

                                  controller:
                                      contentController,

                                  maxLines: 6,
                                ),

                                const SizedBox(
                                  height: 20,
                                ),

                                SizedBox(

                                  width:
                                      double.infinity,

                                  height:
                                      52,

                                  child:
                                      ElevatedButton(

                                    style:
                                        ElevatedButton.styleFrom(

                                      backgroundColor:
                                          const Color(
                                        0xFF16A085,
                                      ),
                                    ),

                                    onPressed:
                                        posting

                                            ? null

                                            : createPost,

                                    child:
                                        posting

                                            ? const CircularProgressIndicator(
                                                color:
                                                    Colors.black,
                                              )

                                            : const Text(

                                                "PUBLISH POST",

                                                style:
                                                    TextStyle(

                                                  color:
                                                      Colors.black,

                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(
                          height: 30,
                        ),

                        sectionTitle(
                          "GLOBAL FEED",
                        ),

                        if (posts.isEmpty)

                          const Padding(

                            padding:
                                EdgeInsets.only(
                              top: 80,
                            ),

                            child: Center(

                              child: Text(

                                "No Posts Available",

                                style:
                                    TextStyle(
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ),
                          ),

                        ...posts.map(
                          postCard,
                        ),

                        const SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}