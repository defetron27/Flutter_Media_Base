import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:date_format/date_format.dart' as DateFormat;

import 'Models/default_main_tv_show_model.dart';
import 'Models/default_main_tv_show_results_model.dart';
import 'Utils/NewPageTransition.dart';
import 'Utils/circle_slider.dart';
import 'Utils/loading_bar_indicator.dart';
import 'tv_show_details.dart';

class MainTvShowsPage extends StatefulWidget {
  MainTvShowsPage({Key key}) : super(key: key);

  _MainTvShowsPageState createState() => _MainTvShowsPageState();
}

class _MainTvShowsPageState extends State<MainTvShowsPage>
    with TickerProviderStateMixin {
  MediaQueryData mediaQueryData;

  double screenWidth;
  double screenHeight;

  var _colors = List<Color>();

  AnimationController mainPageTextEntryAnimationController;

  AnimationController listItemEntryAnimationController;

  AnimationController popularListItemTextEntryAnimationController;
  AnimationController topRatedListItemTextEntryAnimationController;
  AnimationController releasingTodayListItemTextEntryAnimationController;
  AnimationController nowPlayingListItemTextEntryAnimationController;

  AnimationController backPopularListItemChangeAnimationController;
  AnimationController frontPopularListItemChangeAnimationController;

  AnimationController backAnticipatedListItemChangeAnimationController;
  AnimationController frontAnticipatedListItemChangeAnimationController;

  AnimationController backUpcomingListItemChangeAnimationController;
  AnimationController frontUpcomingListItemChangeAnimationController;

  AnimationController backNowPlayingListItemChangeAnimationController;
  AnimationController frontNowPlayingItemChangeAnimationController;

  Animation<double> backPopularListItemChangeAnimation;
  Animation<double> frontPopularListItemChangeAnimation;

  Animation<double> backAnticipatedListItemChangeAnimation;
  Animation<double> frontAnticipatedListItemChangeAnimation;

  Animation<double> backUpcomingListItemChangeAnimation;
  Animation<double> frontUpcomingListItemChangeAnimation;

  Animation<double> backNowPlayingListItemChangeAnimation;
  Animation<double> frontNowPlayingListItemChangeAnimation;

  var tvShowPopularList = List<DefaultMainTvShowResultsModel>();
  var tvShowTopRatedList = List<DefaultMainTvShowResultsModel>();
  var tvShowReleasingTodayList = List<DefaultMainTvShowResultsModel>();
  var tvShowNowPlayingList = List<DefaultMainTvShowResultsModel>();

  PageController popularPageController;
  double popularCurrentPage = 0.0;

  PageController topRatedPageController;
  double topRatedCurrentPage = 0.0;

  PageController releasingTodayPageController;
  double releasingTodayCurrentPage = 0.0;

  PageController nowPlayingPageController;
  double nowPlayingCurrentPage = 0.0;

  ScrollController mainTvPageController;

  PageStorageBucket storageBucket = PageStorageBucket();

  Future fetchPopularItems(int page) async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/popular?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});

    DefaultMainTvShowModel defaultTvShowMainModel =
        DefaultMainTvShowModel.fromJson(json.decode(response.body));

    if (this.mounted) {
      setState(() {
        tvShowPopularList.addAll(defaultTvShowMainModel.results);
        tvShowPopularList.shuffle();
      });
    }

    listItemEntryAnimationController.forward();
    popularListItemTextEntryAnimationController.forward();
  }

  Future fetchTopRatedItems() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/top_rated?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});

    if (this.mounted) {
      setState(() {
        DefaultMainTvShowModel defaultTvShowMainModel =
            DefaultMainTvShowModel.fromJson(json.decode(response.body));
        tvShowTopRatedList = defaultTvShowMainModel.results;
        tvShowTopRatedList.shuffle();
      });
    }

    topRatedListItemTextEntryAnimationController.forward();
  }

  Future fetchReleasingTodayItems() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/airing_today?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});

    if (this.mounted) {
      setState(() {
        DefaultMainTvShowModel defaultTvShowMainModel =
            DefaultMainTvShowModel.fromJson(json.decode(response.body));
        tvShowReleasingTodayList = defaultTvShowMainModel.results;
        tvShowReleasingTodayList.shuffle();
      });
    }

    releasingTodayListItemTextEntryAnimationController.forward();
  }

  Future fetchNowPlayingItems() async {
    final response = await http.get(
        Uri.encodeFull(
            'https://api.themoviedb.org/3/tv/on_the_air?api_key=63e2f7bc00c513994d63c9be541a08d1'),
        headers: {"Accept": "application/json"});

    if (this.mounted) {
      setState(() {
        DefaultMainTvShowModel defaultTvShowMainModel =
            DefaultMainTvShowModel.fromJson(json.decode(response.body));
        tvShowNowPlayingList = defaultTvShowMainModel.results;
        tvShowNowPlayingList.shuffle();
      });
    }

    nowPlayingListItemTextEntryAnimationController.forward();
  }

  @override
  void initState() {
    super.initState();

    mainPageTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    mainPageTextEntryAnimationController.forward();

    listItemEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    popularListItemTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    topRatedListItemTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    releasingTodayListItemTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    nowPlayingListItemTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    backPopularListItemChangeAnimationController = AnimationController(
      vsync: this,
    );
    backPopularListItemChangeAnimationController.forward();

    backPopularListItemChangeAnimation = Tween(
      begin: 0.8,
      end: 1.0,
    ).animate(backPopularListItemChangeAnimationController);

    frontPopularListItemChangeAnimationController = AnimationController(
      vsync: this,
    );
    frontPopularListItemChangeAnimationController.forward();

    frontPopularListItemChangeAnimation = Tween(
      begin: 1.0,
      end: 0.75,
    ).animate(frontPopularListItemChangeAnimationController);

    backAnticipatedListItemChangeAnimationController = AnimationController(
      vsync: this,
    );
    backAnticipatedListItemChangeAnimationController.forward();

    backAnticipatedListItemChangeAnimation = Tween(
      begin: 0.8,
      end: 1.0,
    ).animate(backAnticipatedListItemChangeAnimationController);

    frontAnticipatedListItemChangeAnimationController = AnimationController(
      vsync: this,
    );
    frontAnticipatedListItemChangeAnimationController.forward();

    frontAnticipatedListItemChangeAnimation = Tween(
      begin: 1.0,
      end: 0.75,
    ).animate(frontAnticipatedListItemChangeAnimationController);

    backUpcomingListItemChangeAnimationController = AnimationController(
      vsync: this,
    );
    backUpcomingListItemChangeAnimationController.forward();

    backUpcomingListItemChangeAnimation = Tween(
      begin: 0.8,
      end: 1.0,
    ).animate(backUpcomingListItemChangeAnimationController);

    frontUpcomingListItemChangeAnimationController = AnimationController(
      vsync: this,
    );
    frontUpcomingListItemChangeAnimationController.forward();

    frontUpcomingListItemChangeAnimation = Tween(
      begin: 1.0,
      end: 0.75,
    ).animate(frontUpcomingListItemChangeAnimationController);

    backNowPlayingListItemChangeAnimationController = AnimationController(
      vsync: this,
    );
    backNowPlayingListItemChangeAnimationController.forward();

    backNowPlayingListItemChangeAnimation = Tween(
      begin: 0.8,
      end: 1.0,
    ).animate(backNowPlayingListItemChangeAnimationController);

    frontNowPlayingItemChangeAnimationController = AnimationController(
      vsync: this,
    );
    frontNowPlayingItemChangeAnimationController.forward();

    frontNowPlayingListItemChangeAnimation = Tween(
      begin: 1.0,
      end: 0.75,
    ).animate(frontNowPlayingItemChangeAnimationController);

    Timer(Duration(seconds: 2), () {
      this.fetchPopularItems(1);
    });

    Timer(Duration(seconds: 4), () {
      this.fetchTopRatedItems();
    });

    Timer(Duration(seconds: 6), () {
      this.fetchReleasingTodayItems();
    });

    Timer(Duration(seconds: 8), () {
      this.fetchNowPlayingItems();
    });

    popularPageController = PageController(viewportFraction: 0.75);
    popularPageController.addListener(() {
      setState(() {
        popularCurrentPage = popularPageController.page;
      });
    });

    topRatedPageController = PageController(viewportFraction: 0.75);
    topRatedPageController.addListener(() {
      setState(() {
        topRatedCurrentPage = topRatedPageController.page;
      });
    });

    releasingTodayPageController = PageController(viewportFraction: 0.75);
    releasingTodayPageController.addListener(() {
      setState(() {
        releasingTodayCurrentPage = releasingTodayPageController.page;
      });
    });

    nowPlayingPageController = PageController(viewportFraction: 0.75);
    nowPlayingPageController.addListener(() {
      setState(() {
        nowPlayingCurrentPage = nowPlayingPageController.page;
      });
    });

    mainTvPageController = ScrollController();
    mainTvPageController.addListener(() {
      if (this.mounted) {
        setState(() {});
      }
    });

    _colors.add(Colors.green);
    _colors.add(Colors.blue);
    _colors.add(Colors.yellow);
    _colors.add(Colors.purple);
    _colors.add(Colors.deepOrange);
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    return Scaffold(
      body: Container(
        child: ListView(
          key: PageStorageKey("tv_index1"),
          controller: mainTvPageController,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(
                top: 10.0,
                left: 10.0,
                bottom: 10.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: mainPageTextEntryAnimationController,
                    builder: (context, wdiget) {
                      return Text(
                        "Most Popular",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 18,
                          fontFamily: 'ConcertOne-Regular',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: Colors.black.withOpacity(
                              mainPageTextEntryAnimationController.value),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "View more >",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 14,
                          fontFamily: 'ConcertOne-Regular',
                          fontWeight: FontWeight.w100,
                          color: Colors.white.withOpacity(0.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            tvShowPopularList == null || tvShowPopularList.length == 0
                ? Container(
                    height: 200,
                    color: Colors.transparent,
                    child: Center(
                      child: LoadingBarIndicator(
                        numberOfBars: 5,
                        colors: _colors,
                        barSpacing: 5.0,
                        beginTweenValue: 10.0,
                        endTweenValue: 15.0,
                      ),
                    ),
                  )
                : AnimatedBuilder(
                    animation: listItemEntryAnimationController,
                    builder: (context, widget) {
                      return Opacity(
                        opacity: listItemEntryAnimationController.value,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(
                                3,
                                0,
                                0.006 *
                                    (1 -
                                        listItemEntryAnimationController
                                            .value)),
                          child: Transform.translate(
                            offset: Offset(
                                screenWidth *
                                    (1 -
                                        listItemEntryAnimationController.value),
                                0.0),
                            child: Container(
                              height: 260,
                              color: Colors.transparent,
                              child: PageStorage(
                                bucket: storageBucket,
                                child: PageView.builder(
                                  key: PageStorageKey("index1_most_popular"),
                                  controller: popularPageController,
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  onPageChanged: (index) {
                                    popularListItemTextEntryAnimationController
                                        .reset();
                                    popularListItemTextEntryAnimationController
                                        .forward();
                                  },
                                  itemBuilder: (context, index) {
                                    if (tvShowPopularList[index] != null) {
                                      if (index == popularCurrentPage.floor()) {
                                        frontPopularListItemChangeAnimationController
                                                .value =
                                            (popularCurrentPage - index);

                                        return Transform.scale(
                                          scale:
                                              frontPopularListItemChangeAnimation
                                                  .value,
                                          child: buildTvShowMainListItems(
                                            tvShowPopularList[index].id,
                                            tvShowPopularList[index]
                                                .backdrop_path,
                                            tvShowPopularList[index].name,
                                            tvShowPopularList[index]
                                                .first_air_date
                                                .toString(),
                                            tvShowPopularList[index]
                                                .vote_average,
                                            tvShowPopularList[index].vote_count,
                                            popularListItemTextEntryAnimationController,
                                          ),
                                        );
                                      } else if (index ==
                                          popularCurrentPage.floor() + 1) {
                                        backPopularListItemChangeAnimationController
                                                .value =
                                            1 - (index - popularCurrentPage);
                                        return Opacity(
                                          opacity:
                                              backPopularListItemChangeAnimation
                                                  .value,
                                          child: Transform.scale(
                                            scale:
                                                backPopularListItemChangeAnimation
                                                    .value,
                                            child: buildTvShowMainListItems(
                                              tvShowPopularList[index].id,
                                              tvShowPopularList[index]
                                                  .backdrop_path,
                                              tvShowPopularList[index].name,
                                              tvShowPopularList[index]
                                                  .first_air_date
                                                  .toString(),
                                              tvShowPopularList[index]
                                                  .vote_average,
                                              tvShowPopularList[index]
                                                  .vote_count,
                                              popularListItemTextEntryAnimationController,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Transform.scale(
                                          scale: 0.75,
                                          child: buildTvShowMainListItems(
                                            tvShowPopularList[index].id,
                                            tvShowPopularList[index]
                                                .backdrop_path,
                                            tvShowPopularList[index].name,
                                            tvShowPopularList[index]
                                                .first_air_date
                                                .toString(),
                                            tvShowPopularList[index]
                                                .vote_average,
                                            tvShowPopularList[index].vote_count,
                                            popularListItemTextEntryAnimationController,
                                          ),
                                        );
                                      }
                                    } else {
                                      return Container();
                                    }
                                  },
                                  itemCount: tvShowPopularList.length,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            Container(
              height: 1.0,
              margin: EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: 10.0,
                left: 10.0,
                bottom: 10.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: mainPageTextEntryAnimationController,
                    builder: (context, wdiget) {
                      return Text(
                        "Most Anticipated",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 18,
                          fontFamily: 'ConcertOne-Regular',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: Colors.black.withOpacity(
                              mainPageTextEntryAnimationController.value),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "View more >",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 14,
                          fontFamily: 'ConcertOne-Regular',
                          fontWeight: FontWeight.w100,
                          color: Colors.white.withOpacity(0.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            tvShowTopRatedList == null || tvShowTopRatedList.length == 0
                ? Container(
                    height: 200,
                    color: Colors.transparent,
                    child: Center(
                      child: LoadingBarIndicator(
                        numberOfBars: 5,
                        colors: _colors,
                        barSpacing: 5.0,
                        beginTweenValue: 10.0,
                        endTweenValue: 15.0,
                      ),
                    ),
                  )
                : AnimatedBuilder(
                    animation: listItemEntryAnimationController,
                    builder: (context, widget) {
                      return Opacity(
                        opacity: listItemEntryAnimationController.value,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(
                                3,
                                0,
                                0.006 *
                                    (1 -
                                        listItemEntryAnimationController
                                            .value)),
                          child: Transform.translate(
                            offset: Offset(
                                screenWidth *
                                    (1 -
                                        listItemEntryAnimationController.value),
                                0.0),
                            child: Container(
                              height: 260,
                              color: Colors.transparent,
                              child: PageStorage(
                                bucket: storageBucket,
                                child: PageView.builder(
                                  key: PageStorageKey("index1_top_rated"),
                                  controller: topRatedPageController,
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  onPageChanged: (index) {
                                    topRatedListItemTextEntryAnimationController
                                        .reset();
                                    topRatedListItemTextEntryAnimationController
                                        .forward();
                                  },
                                  itemBuilder: (context, index) {
                                    if (index == topRatedCurrentPage.floor()) {
                                      frontAnticipatedListItemChangeAnimationController
                                              .value =
                                          (topRatedCurrentPage - index);

                                      return Transform.scale(
                                        scale:
                                            frontAnticipatedListItemChangeAnimation
                                                .value,
                                        child: buildTvShowMainListItems(
                                          tvShowTopRatedList[index].id,
                                          tvShowTopRatedList[index]
                                              .backdrop_path,
                                          tvShowTopRatedList[index].name,
                                          tvShowTopRatedList[index]
                                              .first_air_date
                                              .toString(),
                                          tvShowTopRatedList[index]
                                              .vote_average,
                                          tvShowTopRatedList[index].vote_count,
                                          topRatedListItemTextEntryAnimationController,
                                        ),
                                      );
                                    } else if (index ==
                                        topRatedCurrentPage.floor() + 1) {
                                      backAnticipatedListItemChangeAnimationController
                                              .value =
                                          1 - (index - topRatedCurrentPage);

                                      return Opacity(
                                        opacity:
                                            backAnticipatedListItemChangeAnimation
                                                .value,
                                        child: Transform.scale(
                                          scale:
                                              backAnticipatedListItemChangeAnimation
                                                  .value,
                                          child: buildTvShowMainListItems(
                                            tvShowTopRatedList[index].id,
                                            tvShowTopRatedList[index]
                                                .backdrop_path,
                                            tvShowTopRatedList[index].name,
                                            tvShowTopRatedList[index]
                                                .first_air_date
                                                .toString(),
                                            tvShowTopRatedList[index]
                                                .vote_average,
                                            tvShowTopRatedList[index]
                                                .vote_count,
                                            topRatedListItemTextEntryAnimationController,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Transform.scale(
                                        scale: 0.75,
                                        child: buildTvShowMainListItems(
                                          tvShowTopRatedList[index].id,
                                          tvShowTopRatedList[index]
                                              .backdrop_path,
                                          tvShowTopRatedList[index].name,
                                          tvShowTopRatedList[index]
                                              .first_air_date
                                              .toString(),
                                          tvShowTopRatedList[index]
                                              .vote_average,
                                          tvShowTopRatedList[index].vote_count,
                                          topRatedListItemTextEntryAnimationController,
                                        ),
                                      );
                                    }
                                  },
                                  itemCount: tvShowTopRatedList.length,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            Container(
              height: 1.0,
              margin: EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: 10.0,
                left: 10.0,
                bottom: 10.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: mainPageTextEntryAnimationController,
                    builder: (context, wdiget) {
                      return Text(
                        "Upcoming",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 18,
                          fontFamily: 'ConcertOne-Regular',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: Colors.black.withOpacity(
                              mainPageTextEntryAnimationController.value),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "View more >",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 14,
                          fontFamily: 'ConcertOne-Regular',
                          fontWeight: FontWeight.w100,
                          color: Colors.white.withOpacity(0.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            tvShowReleasingTodayList == null ||
                    tvShowReleasingTodayList.length == 0
                ? Container(
                    height: 200,
                    color: Colors.transparent,
                    child: Center(
                      child: LoadingBarIndicator(
                        numberOfBars: 5,
                        colors: _colors,
                        barSpacing: 5.0,
                        beginTweenValue: 10.0,
                        endTweenValue: 15.0,
                      ),
                    ),
                  )
                : AnimatedBuilder(
                    animation: listItemEntryAnimationController,
                    builder: (context, widget) {
                      return Opacity(
                        opacity: listItemEntryAnimationController.value,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(
                                3,
                                0,
                                0.006 *
                                    (1 -
                                        listItemEntryAnimationController
                                            .value)),
                          child: Transform.translate(
                            offset: Offset(
                                screenWidth *
                                    (1 -
                                        listItemEntryAnimationController.value),
                                0.0),
                            child: Container(
                              height: 250,
                              color: Colors.white,
                              child: PageStorage(
                                bucket: storageBucket,
                                child: PageView.builder(
                                  key: PageStorageKey("index1_releasing_today"),
                                  controller: releasingTodayPageController,
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  onPageChanged: (index) {
                                    releasingTodayListItemTextEntryAnimationController
                                        .reset();
                                    releasingTodayListItemTextEntryAnimationController
                                        .forward();
                                  },
                                  itemBuilder: (context, index) {
                                    if (index ==
                                        releasingTodayCurrentPage.floor()) {
                                      frontUpcomingListItemChangeAnimationController
                                              .value =
                                          (releasingTodayCurrentPage - index);

                                      return Transform.scale(
                                        scale:
                                            frontUpcomingListItemChangeAnimation
                                                .value,
                                        child: buildTvShowMainListItems(
                                          tvShowReleasingTodayList[index].id,
                                          tvShowReleasingTodayList[index]
                                              .backdrop_path,
                                          tvShowReleasingTodayList[index].name,
                                          tvShowReleasingTodayList[index]
                                              .first_air_date
                                              .toString(),
                                          tvShowReleasingTodayList[index]
                                              .vote_average,
                                          tvShowReleasingTodayList[index]
                                              .vote_count,
                                          releasingTodayListItemTextEntryAnimationController,
                                        ),
                                      );
                                    } else if (index ==
                                        releasingTodayCurrentPage.floor() + 1) {
                                      backUpcomingListItemChangeAnimationController
                                              .value =
                                          1 -
                                              (index -
                                                  releasingTodayCurrentPage);

                                      return Opacity(
                                        opacity:
                                            backUpcomingListItemChangeAnimation
                                                .value,
                                        child: Transform.scale(
                                          scale:
                                              backUpcomingListItemChangeAnimation
                                                  .value,
                                          child: buildTvShowMainListItems(
                                            tvShowReleasingTodayList[index].id,
                                            tvShowReleasingTodayList[index]
                                                .backdrop_path,
                                            tvShowReleasingTodayList[index]
                                                .name,
                                            tvShowReleasingTodayList[index]
                                                .first_air_date
                                                .toString(),
                                            tvShowReleasingTodayList[index]
                                                .vote_average,
                                            tvShowReleasingTodayList[index]
                                                .vote_count,
                                            releasingTodayListItemTextEntryAnimationController,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Transform.scale(
                                        scale: 0.75,
                                        child: buildTvShowMainListItems(
                                          tvShowReleasingTodayList[index].id,
                                          tvShowReleasingTodayList[index]
                                              .backdrop_path,
                                          tvShowReleasingTodayList[index].name,
                                          tvShowReleasingTodayList[index]
                                              .first_air_date
                                              .toString(),
                                          tvShowReleasingTodayList[index]
                                              .vote_average,
                                          tvShowReleasingTodayList[index]
                                              .vote_count,
                                          releasingTodayListItemTextEntryAnimationController,
                                        ),
                                      );
                                    }
                                  },
                                  itemCount: tvShowReleasingTodayList.length,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            Container(
              height: 1.0,
              margin: EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: 10.0,
                left: 10.0,
                bottom: 10.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AnimatedBuilder(
                    animation: mainPageTextEntryAnimationController,
                    builder: (context, wdiget) {
                      return Text(
                        "Now Playing",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 18,
                          fontFamily: 'ConcertOne-Regular',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          color: Colors.black.withOpacity(
                              mainPageTextEntryAnimationController.value),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "View more >",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          fontSize: 14,
                          fontFamily: 'ConcertOne-Regular',
                          fontWeight: FontWeight.w100,
                          color: Colors.white.withOpacity(0.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            tvShowNowPlayingList == null || tvShowNowPlayingList.length == 0
                ? Container(
                    height: 200,
                    color: Colors.transparent,
                    child: Center(
                      child: LoadingBarIndicator(
                        numberOfBars: 5,
                        colors: _colors,
                        barSpacing: 5.0,
                        beginTweenValue: 10.0,
                        endTweenValue: 15.0,
                      ),
                    ),
                  )
                : AnimatedBuilder(
                    animation: listItemEntryAnimationController,
                    builder: (context, widget) {
                      return Opacity(
                        opacity: listItemEntryAnimationController.value,
                        child: Transform(
                          transform: Matrix4.identity()
                            ..setEntry(
                                3,
                                0,
                                0.006 *
                                    (1 -
                                        listItemEntryAnimationController
                                            .value)),
                          child: Transform.translate(
                            offset: Offset(
                                screenWidth *
                                    (1 -
                                        listItemEntryAnimationController.value),
                                0.0),
                            child: Container(
                              height: 260,
                              color: Colors.white,
                              child: PageStorage(
                                bucket: storageBucket,
                                child: PageView.builder(
                                  key: PageStorageKey("index1_now_playing"),
                                  controller: nowPlayingPageController,
                                  scrollDirection: Axis.horizontal,
                                  physics: BouncingScrollPhysics(),
                                  onPageChanged: (index) {
                                    nowPlayingListItemTextEntryAnimationController
                                        .reset();
                                    nowPlayingListItemTextEntryAnimationController
                                        .forward();
                                  },
                                  itemBuilder: (context, index) {
                                    if (index ==
                                        nowPlayingCurrentPage.floor()) {
                                      frontNowPlayingItemChangeAnimationController
                                              .value =
                                          (nowPlayingCurrentPage - index);

                                      return Transform.scale(
                                        scale:
                                            frontNowPlayingListItemChangeAnimation
                                                .value,
                                        child: buildTvShowMainListItems(
                                          tvShowNowPlayingList[index].id,
                                          tvShowNowPlayingList[index]
                                              .backdrop_path,
                                          tvShowNowPlayingList[index].name,
                                          tvShowNowPlayingList[index]
                                              .first_air_date
                                              .toString(),
                                          tvShowNowPlayingList[index]
                                              .vote_average,
                                          tvShowNowPlayingList[index]
                                              .vote_count,
                                          nowPlayingListItemTextEntryAnimationController,
                                        ),
                                      );
                                    } else if (index ==
                                        nowPlayingCurrentPage.floor() + 1) {
                                      backNowPlayingListItemChangeAnimationController
                                              .value =
                                          1 - (index - nowPlayingCurrentPage);

                                      return Opacity(
                                        opacity:
                                            backNowPlayingListItemChangeAnimation
                                                .value,
                                        child: Transform.scale(
                                          scale:
                                              backNowPlayingListItemChangeAnimation
                                                  .value,
                                          child: buildTvShowMainListItems(
                                            tvShowNowPlayingList[index].id,
                                            tvShowNowPlayingList[index]
                                                .backdrop_path,
                                            tvShowNowPlayingList[index].name,
                                            tvShowNowPlayingList[index]
                                                .first_air_date
                                                .toString(),
                                            tvShowNowPlayingList[index]
                                                .vote_average,
                                            tvShowNowPlayingList[index]
                                                .vote_count,
                                            nowPlayingListItemTextEntryAnimationController,
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Transform.scale(
                                        scale: 0.75,
                                        child: buildTvShowMainListItems(
                                          tvShowNowPlayingList[index].id,
                                          tvShowNowPlayingList[index]
                                              .backdrop_path,
                                          tvShowNowPlayingList[index].name,
                                          tvShowNowPlayingList[index]
                                              .first_air_date
                                              .toString(),
                                          tvShowNowPlayingList[index]
                                              .vote_average,
                                          tvShowNowPlayingList[index]
                                              .vote_count,
                                          nowPlayingListItemTextEntryAnimationController,
                                        ),
                                      );
                                    }
                                  },
                                  itemCount: tvShowNowPlayingList.length,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget buildTvShowMainListItems(
    int id,
    String imageUrl,
    String name,
    String releaseDate,
    double rating,
    int voteCount,
    AnimationController _animationController,
  ) {
    String newName = name == null || name == "" || name.length <= 0
        ? ""
        : name.length > 15 ? name.substring(0, 15) + "..." : name;

    String formatReleaseDate = releaseDate != null && releaseDate != ""
        ? releaseDate.replaceAll(
            RegExp(
              "-",
              caseSensitive: false,
            ),
            "")
        : "";

    var dateTime = DateTime.parse(
        releaseDate != null && releaseDate != "" ? formatReleaseDate : "");

    var newReleaseDate = DateFormat.formatDate(
        dateTime, [DateFormat.dd, " ", DateFormat.M, " ", DateFormat.yyyy]);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          NewPageTransition(
            widget: TvShowDetails(
              tvShowId: id,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: 20.0,
          top: 10.0,
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 250.0,
                width: screenWidth - 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2.0,
                      blurRadius: 5.0,
                    ),
                  ],
                  color: Colors.white,
                ),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, wdiget) {
                    return Stack(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topRight,
                          child: CircleSlider(
                            backgroundColor: Colors.white,
                            backgroundMargin: EdgeInsets.all(0.0),
                            backgroundBorderRadius: BorderRadius.all(
                              Radius.circular(
                                10.0,
                              ),
                            ),
                            width: 100,
                            height: 100,
                            sliderSize: 30.0,
                            sliderColor: Colors.deepPurple,
                            sliderPercentage: rating * 10,
                            sliderController: _animationController,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: screenWidth,
                            margin: EdgeInsets.only(
                              right: 20.0,
                              left: 15.0,
                              bottom: 20.0,
                            ),
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      newName,
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontFamily: "ConcertOne-Regular",
                                        color: Colors.black.withOpacity(
                                            _animationController.value),
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  margin: EdgeInsets.only(
                                    top: 7.0,
                                  ),
                                  child: Text(
                                    newReleaseDate,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(
                                          _animationController.value),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 90,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[400],
                                  spreadRadius: 0.0,
                                  blurRadius: 2.0,
                                ),
                              ],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomRight: Radius.circular(10.0),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.red[700].withOpacity(
                                          _animationController.value),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      left: 5.0,
                                      right: 5.0,
                                      bottom: 5.0,
                                    ),
                                    child: Text(
                                      voteCount != null
                                          ? voteCount.toString()
                                          : "0",
                                      style: TextStyle(
                                        fontFamily: "ConcertOne-Regular",
                                        color: Colors.black.withOpacity(
                                          _animationController.value,
                                        ),
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Transform.translate(
                offset: Offset(-15.0, 5.0),
                child: Container(
                  transform: Matrix4.identity()..setEntry(3, 0, 0.0015),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 5.0,
                        offset: Offset(-4.0, 3.0),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    child: imageUrl == null || imageUrl == ""
                        ? Container(
                            height: 150.0,
                            color: Colors.grey,
                            child: Icon(
                              Icons.live_tv,
                              color: Colors.grey[100],
                              size: 80,
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
