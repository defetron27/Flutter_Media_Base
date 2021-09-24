import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:media_base/main_movies_page.dart';
import 'package:media_base/main_persons_page.dart';
import 'package:media_base/main_tv_shows_page.dart';
import 'package:vector_math/vector_math_64.dart' as VectorMath64;
import 'package:date_format/date_format.dart' as DateFormat;

import 'Models/default_main_movie_model.dart';
import 'Models/default_main_movie_results_model.dart';
import 'Models/default_main_person_model.dart';
import 'Models/default_main_person_results_model.dart';
import 'Models/default_main_tv_show_model.dart';
import 'Models/default_main_tv_show_results_model.dart';

import 'Utils/circle_slider.dart';
import 'Utils/loading_bar_indicator.dart';
import 'Utils/NewPageTransition.dart';
import 'Utils/custom_curved_navigation_bar.dart';

import 'tv_show_details.dart';

void main() => runApp(MaterialApp(
      title: "Media Base",
      debugShowCheckedModeBanner: false,
      home: MediaBase(),
    ));

class MediaBase extends StatefulWidget {
  MediaBase({Key key}) : super(key: key);

  _MediaBaseState createState() => _MediaBaseState();
}

class _MediaBaseState extends State<MediaBase> with TickerProviderStateMixin {
  MediaQueryData mediaQueryData;

  double screenWidth;
  double screenHeight;

  int _currentIndex = 1;

  int _currentSliderIndex = 0;

  List<Color> _bgColorList = [
    Colors.green[400],
    Colors.deepPurple[400],
    Colors.blue[400],
  ];

  List _tabBarTextList = ["Tv Shows", "Movies", "Celebrities"];

  List<Widget> iconList(double _size, Color _color) {
    var iconList = List<Widget>();

    iconList.add(Icon(
      Icons.live_tv,
      size: _size,
      color: _color,
    ));
    iconList.add(Icon(
      Icons.movie,
      size: _size,
      color: _color,
    ));
    iconList.add(Icon(
      Icons.people_outline,
      size: _size,
      color: _color,
    ));

    return iconList;
  }

  var _colors = List<Color>();

  var sliderItemDetailsList = List<Map<String, String>>();
  var customSliderItemDetailsList = List<Map<String, String>>();

  var tvShowSuggestionList = List<String>();

  AnimationController dragAnimationController;
  AnimationController sliderAnimationController;
  AnimationController sliderEntryAnimationController;
  AnimationController sliderTextEntryAnimationController;

  double defaultSlidingValue = 1.0 / 4.0;

  double currentSlidingValue = 1.0 / 4.0;

  int currentSliderIndex = 0;

  bool _animationStatus = false;

  int endTvRange;
  int beginMovieRange;
  int endMovieRange;
  int beginPersonRange;
  int endPersonRange;
  int beginGameRange;
  int endGameRange;

  Animation<double> heightFactorAnimation;
  Animation<double> cornerRadiusAnimation;
  Animation<double> colorOpacityAnimation;
  Animation<double> opacityAnimation;
  Animation<double> sliderTextEntryAnimation;
  Animation<double> sliderTopCenterOpacityAnimation;

  double collapsedHeightFactor = 0.60;
  double expandedHeightFactor = 0.20;

  double collapsedCornerRadius = 0.0;
  double expandedCornerRadius = 30.0;

  double expandedColorOpacity = 0.0;
  double collapsedColorOpacity = 1.0;

  double expandedOpacity = 1.0;
  double collapsedOpacity = 0.0;

  double collapsedSliderTopCenterOpacity = 0.0;
  double expandedSliderTopCenterOpacity = 0.2;

  PageController mainSliderPageController;
  double mainSliderCurrentPage = 0.0;

  var tvTrendingList = List<DefaultMainTvShowResultsModel>();
  var movieTrendingList = List<DefaultMainMovieResultsModel>();
  var personTrendingList = List<DefaultMainPersonResultsModel>();

  Future fetchMainSliderItems() async {
    var _sliderItemDetails = List<Map<String, String>>();

    DefaultMainTvShowModel tvResponseModel;
    DefaultMainMovieModel movieResponseModel;
    DefaultMainPersonModel personResponseModel;

    final tvResponse = await http.get(
      Uri.encodeFull(
          'https://api.themoviedb.org/3/trending/tv/day?api_key=63e2f7bc00c513994d63c9be541a08d1'),
      headers: {
        "Accept": "application/json",
      },
    );

    final movieResponse = await http.get(
      Uri.encodeFull(
          'https://api.themoviedb.org/3/trending/movie/day?api_key=63e2f7bc00c513994d63c9be541a08d1'),
      headers: {
        "Accept": "application/json",
      },
    );

    final personResponse = await http.get(
      Uri.encodeFull(
          'https://api.themoviedb.org/3/trending/person/day?api_key=63e2f7bc00c513994d63c9be541a08d1'),
      headers: {
        "Accept": "application/json",
      },
    );

    if (this.mounted) {
      setState(() {
        if (tvResponse.statusCode == 200) {
          tvResponseModel =
              DefaultMainTvShowModel.fromJson(json.decode(tvResponse.body));
        }

        if (movieResponse.statusCode == 200) {
          movieResponseModel =
              DefaultMainMovieModel.fromJson(json.decode(movieResponse.body));
        }

        if (personResponse.statusCode == 200) {
          personResponseModel =
              DefaultMainPersonModel.fromJson(json.decode(personResponse.body));
        }

        if (tvResponseModel != null && tvResponseModel.results.length > 0) {
          tvTrendingList = tvResponseModel.results;
        }

        if (movieResponseModel != null &&
            movieResponseModel.results.length > 0) {
          movieTrendingList = movieResponseModel.results;
        }

        if (personResponseModel != null &&
            personResponseModel.results.length > 0) {
          personTrendingList = personResponseModel.results;
        }

        if (tvTrendingList != null && tvTrendingList.length > 0) {
          for (DefaultMainTvShowResultsModel tvTrending in tvTrendingList) {
            if (tvTrending.name != null && tvTrending.name != "") {
              tvShowSuggestionList.add(tvTrending.name);
            }
          }

          for (DefaultMainTvShowResultsModel tvTrending in tvTrendingList) {
            if (tvTrending.name != null &&
                tvTrending.name != "" &&
                tvTrending.backdrop_path != null &&
                tvTrending.backdrop_path != "") {
              if (_sliderItemDetails.length <= 3) {
                _sliderItemDetails.add({
                  "imageUrl": tvTrending.backdrop_path,
                  "name": tvTrending.name
                });
              } else {
                break;
              }
            }
          }

          if (_sliderItemDetails != null && _sliderItemDetails.length > 0) {
            sliderItemDetailsList.addAll(_sliderItemDetails);
            endTvRange = _sliderItemDetails.length;
            beginMovieRange = endTvRange;
            _sliderItemDetails.clear();
          }
        }

        if (movieTrendingList != null && movieTrendingList.length > 0) {
          for (DefaultMainMovieResultsModel movieTrending
              in movieTrendingList) {
            if (movieTrending.title != null &&
                movieTrending.title != "" &&
                movieTrending.backdrop_path != null &&
                movieTrending.backdrop_path != "") {
              if (_sliderItemDetails.length <= 3) {
                _sliderItemDetails.add({
                  "imageUrl": movieTrending.backdrop_path,
                  "name": movieTrending.title
                });
              } else {
                break;
              }
            }
          }

          if (_sliderItemDetails != null && _sliderItemDetails.length > 0) {
            sliderItemDetailsList.addAll(_sliderItemDetails);
            endMovieRange = beginMovieRange + _sliderItemDetails.length;
            beginPersonRange = endMovieRange;
            _sliderItemDetails.clear();
          }
        }

        if (personTrendingList != null && personTrendingList.length > 0) {
          for (DefaultMainPersonResultsModel personTrending
              in personTrendingList) {
            if (personTrending.name != null &&
                personTrending.name != "" &&
                personTrending.profile_path != null &&
                personTrending.profile_path != "") {
              if (_sliderItemDetails.length <= 3) {
                _sliderItemDetails.add({
                  "imageUrl": personTrending.profile_path,
                  "name": personTrending.name
                });
              } else {
                break;
              }
            }
          }

          if (_sliderItemDetails != null && _sliderItemDetails.length > 0) {
            sliderItemDetailsList.addAll(_sliderItemDetails);
            endPersonRange = beginPersonRange + _sliderItemDetails.length;
            beginGameRange = endPersonRange;
            _sliderItemDetails.clear();
          }
        }

        if (sliderItemDetailsList != null && sliderItemDetailsList.length > 0) {
          if (_currentIndex == 0) {
            customSliderItemDetailsList.clear();
            customSliderItemDetailsList =
                sliderItemDetailsList.sublist(0, endTvRange);

            customSliderItemDetailsList.shuffle();
          } else if (_currentIndex == 1) {
            customSliderItemDetailsList.clear();
            customSliderItemDetailsList =
                sliderItemDetailsList.sublist(beginMovieRange, endMovieRange);

            customSliderItemDetailsList.shuffle();
          } else if (_currentIndex == 2) {
            customSliderItemDetailsList.clear();
            customSliderItemDetailsList =
                sliderItemDetailsList.sublist(beginPersonRange, endPersonRange);

            customSliderItemDetailsList.shuffle();
          }

          if (customSliderItemDetailsList != null &&
              customSliderItemDetailsList.length > 0) {
            double sliderLength = customSliderItemDetailsList.length.toDouble();

            defaultSlidingValue = 1.0 / sliderLength;
            currentSlidingValue = 1.0 / sliderLength;
          }
        }
      });
    }
  }

  PageStorageBucket storageBucket = PageStorageBucket();

  @override
  void initState() {
    super.initState();

    this.fetchMainSliderItems();

    mainSliderPageController = PageController();
    mainSliderPageController.addListener(() {
      setState(() {
        mainSliderCurrentPage = mainSliderPageController.page;
      });
    });

    dragAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );

    heightFactorAnimation =
        Tween(begin: collapsedHeightFactor, end: expandedHeightFactor)
            .animate(dragAnimationController);

    cornerRadiusAnimation =
        Tween(begin: expandedCornerRadius, end: collapsedCornerRadius)
            .animate(dragAnimationController);

    colorOpacityAnimation =
        Tween(begin: expandedColorOpacity, end: collapsedColorOpacity)
            .animate(dragAnimationController);

    opacityAnimation = Tween(begin: expandedOpacity, end: collapsedOpacity)
        .animate(dragAnimationController);

    sliderTopCenterOpacityAnimation = Tween(
            begin: expandedSliderTopCenterOpacity,
            end: collapsedSliderTopCenterOpacity)
        .animate(dragAnimationController);

    sliderAnimationController = AnimationController(
      duration: Duration(seconds: 60),
      vsync: this,
    );
    sliderAnimationController.forward();

    sliderAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        sliderAnimationController.reverse();
        setState(() {
          _animationStatus = true;
        });
      } else if (status == AnimationStatus.dismissed) {
        sliderAnimationController.forward();
        setState(() {
          _animationStatus = false;
        });
      }
    });

    sliderAnimationController.addListener(() {
      if (sliderAnimationController.value >= defaultSlidingValue) {
        if (_animationStatus) {
          if (sliderAnimationController.value <= currentSlidingValue) {
            if (this.mounted) {
              setState(() {
                currentSlidingValue = currentSlidingValue - defaultSlidingValue;
                currentSliderIndex =
                    currentSliderIndex > 0 ? currentSliderIndex - 1 : 0;

                if (mainSliderPageController.hasClients) {
                  mainSliderPageController.animateToPage(
                    currentSliderIndex,
                    duration: Duration(seconds: 1),
                    curve: Curves.easeInOutCubic,
                  );
                }
              });
            }
          }
        } else {
          if (sliderAnimationController.value > currentSlidingValue) {
            if (this.mounted) {
              setState(() {
                currentSlidingValue = currentSlidingValue + defaultSlidingValue;

                currentSliderIndex = currentSliderIndex + 1;

                if (mainSliderPageController.hasClients) {
                  mainSliderPageController.animateToPage(
                    currentSliderIndex,
                    duration: Duration(seconds: 1),
                    curve: Curves.easeInOutCubic,
                  );
                }
              });
            }
          }
        }
      }
    });

    sliderEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    sliderEntryAnimationController.forward();

    sliderTextEntryAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    sliderTextEntryAnimationController.forward();

    sliderTextEntryAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(sliderTextEntryAnimationController);

    _colors.add(Colors.green);
    _colors.add(Colors.blue);
    _colors.add(Colors.yellow);
    _colors.add(Colors.purple);
    _colors.add(Colors.deepOrange);
  }

  @override
  void dispose() {
    dragAnimationController.dispose();
    sliderAnimationController.dispose();
    sliderEntryAnimationController.dispose();
    sliderTextEntryAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);

    screenWidth = mediaQueryData.size.width;
    screenHeight = mediaQueryData.size.height;

    return AnimatedBuilder(
      animation: sliderEntryAnimationController,
      builder: (context, widget) {
        return Scaffold(
          bottomNavigationBar: CustomCurvedNavigationBar(
            index: _currentIndex,
            buttonBackgroundColor: _bgColorList[_currentIndex],
            color: _bgColorList[_currentIndex],
            animationCurve: Curves.easeInOut,
            height: 60.0,
            items: iconList(25.0, Colors.white),
            onTap: (index) {
              if (this.mounted) {
                setState(() {
                  _currentIndex = index;

                  if (sliderItemDetailsList != null &&
                      sliderItemDetailsList.length > 0) {
                    if (_currentIndex == 0) {
                      customSliderItemDetailsList.clear();
                      customSliderItemDetailsList =
                          sliderItemDetailsList.sublist(0, endTvRange);
                      customSliderItemDetailsList.shuffle();
                    } else if (_currentIndex == 1) {
                      customSliderItemDetailsList.clear();
                      customSliderItemDetailsList = sliderItemDetailsList
                          .sublist(beginMovieRange, endMovieRange);
                      customSliderItemDetailsList.shuffle();
                    } else if (_currentIndex == 2) {
                      customSliderItemDetailsList.clear();
                      customSliderItemDetailsList = sliderItemDetailsList
                          .sublist(beginPersonRange, endPersonRange);
                      customSliderItemDetailsList.shuffle();
                    }
                  }
                });
              }

              sliderEntryAnimationController.reset();
              sliderEntryAnimationController.forward();

              sliderTextEntryAnimationController.reset();
              sliderTextEntryAnimationController.forward();
            },
          ),
          body: Container(
            color: _bgColorList[_currentIndex],
            child: AnimatedBuilder(
              animation: dragAnimationController,
              builder: (context, widget) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: heightFactorAnimation.value,
                      child: customSliderItemDetailsList == null ||
                              customSliderItemDetailsList.length <= 0
                          ? iconList(
                              80.0,
                              Colors.white.withOpacity(opacityAnimation.value),
                            )[_currentIndex]
                          : PageView.builder(
                              physics: BouncingScrollPhysics(),
                              controller: mainSliderPageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentSliderIndex = index;
                                });
                                sliderTextEntryAnimationController.reset();
                                sliderTextEntryAnimationController.forward();
                              },
                              itemBuilder: (context, index) {
                                if (customSliderItemDetailsList[index]
                                            ["imageUrl"] ==
                                        null ||
                                    customSliderItemDetailsList[index]
                                            ["imageUrl"] ==
                                        "") {
                                  return iconList(
                                      80.0,
                                      Colors.white.withOpacity(opacityAnimation
                                          .value))[_currentIndex];
                                }
                                return AnimatedBuilder(
                                  animation: sliderEntryAnimationController,
                                  builder: (context, widget) {
                                    return buildMainSliderListItems(
                                      customSliderItemDetailsList[index],
                                      mainSliderCurrentPage,
                                      index,
                                    );
                                  },
                                );
                              },
                              itemCount: customSliderItemDetailsList.length,
                            ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: expandedHeightFactor - 0.01,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: Icon(
                                Icons.menu,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 15.0,
                                bottom: 6.0,
                              ),
                              child: Text(
                                _tabBarTextList[_currentIndex],
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: "ConcertOne-Regular",
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              child: IconButton(
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  showSearch(
                                      context: context,
                                      delegate:
                                          TvDataSearch(tvShowSuggestionList));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FractionallySizedBox(
                      alignment: Alignment.bottomCenter,
                      heightFactor: 1.16 - heightFactorAnimation.value,
                      child: _currentSliderIndex == null ||
                              customSliderItemDetailsList == null ||
                              customSliderItemDetailsList.length <= 0
                          ? Container()
                          : AnimatedBuilder(
                              animation: sliderTextEntryAnimationController,
                              builder: (context, widget) {
                                return Opacity(
                                  opacity: sliderTextEntryAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.center,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(
                                              opacityAnimation.value),
                                          Colors.black.withOpacity(
                                            sliderTopCenterOpacityAnimation
                                                .value,
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: Opacity(
                                      opacity: opacityAnimation.value,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.topCenter,
                                            child: Text(
                                              _currentSliderIndex == null
                                                  ? ""
                                                  : customSliderItemDetailsList[
                                                                      _currentSliderIndex]
                                                                  ["name"] ==
                                                              null ||
                                                          customSliderItemDetailsList[
                                                                      _currentSliderIndex]
                                                                  ["name"] ==
                                                              ""
                                                      ? ""
                                                      : customSliderItemDetailsList[
                                                              _currentSliderIndex]
                                                          ["name"],
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily:
                                                    "ConcertOne-Regular",
                                                color: Colors.white.withOpacity(
                                                    sliderTextEntryAnimation
                                                        .value),
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          _currentSliderIndex == null ||
                                                  customSliderItemDetailsList ==
                                                      null ||
                                                  customSliderItemDetailsList
                                                          .length <=
                                                      0
                                              ? Container()
                                              : Expanded(
                                                  child: Container(
                                                    width: screenWidth - 245,
                                                    margin:
                                                        EdgeInsets.all(10.0),
                                                    child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (_currentSliderIndex ==
                                                            index) {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              mainSliderPageController
                                                                  .animateToPage(
                                                                index,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                curve: Curves
                                                                    .easeInOutCubic,
                                                              );
                                                            },
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child:
                                                                  AnimatedContainer(
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        300),
                                                                height: 10.0,
                                                                width: 10.0,
                                                                margin:
                                                                    EdgeInsets
                                                                        .only(
                                                                  left: 10.0,
                                                                  right: 10.0,
                                                                  top: 5.0,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Colors
                                                                        .white,
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .white,
                                                                        spreadRadius:
                                                                            1.0,
                                                                      ),
                                                                    ]),
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          return GestureDetector(
                                                            onTap: () {
                                                              mainSliderPageController
                                                                  .animateToPage(
                                                                index,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            1),
                                                                curve: Curves
                                                                    .easeInOutCubic,
                                                              );
                                                            },
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              child:
                                                                  AnimatedContainer(
                                                                duration: Duration(
                                                                    milliseconds:
                                                                        400),
                                                                height: 8.0,
                                                                width: 8.0,
                                                                margin: EdgeInsets
                                                                    .all(10.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border
                                                                      .all(
                                                                    width: 1.0,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                      itemCount:
                                                          customSliderItemDetailsList
                                                              .length,
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    GestureDetector(
                      onVerticalDragUpdate: (verticalDragDetails) {
                        //double startAt = ((1.05 - heightFactorAnimation.value) * 100) + 100;

                        // if (mainTvPageController.offset > startAt) {
                        //   dragAnimationController.forward();
                        // } else if (mainTvPageController.offset <= 0.0) {
                        //   dragAnimationController.reverse();
                        // }

                        // if (mainTvPageController.offset <= startAt) {
                        //   dragAnimationController.value =
                        //       mainTvPageController.offset / startAt;
                        // }

                        double fractionalDragged =
                            verticalDragDetails.primaryDelta / screenHeight;
                        dragAnimationController.value =
                            dragAnimationController.value -
                                (5 * fractionalDragged);
                      },
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: 1.05 - heightFactorAnimation.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft:
                                  Radius.circular(cornerRadiusAnimation.value),
                              topRight:
                                  Radius.circular(cornerRadiusAnimation.value),
                            ),
                          ),
                          child: PageStorage(
                            bucket: storageBucket,
                            child: buildMainPageItems(currentSliderIndex
                            
                            
                            
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildMainSliderListItems(Map<String, String> sliderDetails,
      double mainSliderCurrentPage, int index) {
    if (index == mainSliderCurrentPage.floor()) {
      return Container(
        transform: Matrix4.identity()
          ..setFromTranslationRotationScale(
            VectorMath64.Vector3(
              -screenWidth * (index - mainSliderCurrentPage),
              0.0,
              0.0,
            ),
            VectorMath64.Quaternion(
              0.0,
              0.0,
              0.0,
              0.0,
            ),
            VectorMath64.Vector3(
              1 - (mainSliderCurrentPage - index),
              1,
              1,
            ),
          ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              sliderDetails["imageUrl"],
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              _bgColorList[_currentIndex]
                  .withOpacity(colorOpacityAnimation.value),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Container(
          color: Colors.white
              .withOpacity(1 - sliderEntryAnimationController.value),
        ),
      );
    } else if (index == mainSliderCurrentPage.floor() + 1) {
      return Container(
        transform: Matrix4.identity()
          ..setEntry(3, 0, 0.006 * -(mainSliderCurrentPage - index)),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              sliderDetails["imageUrl"],
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              _bgColorList[_currentIndex]
                  .withOpacity(colorOpacityAnimation.value),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Container(
          color: Colors.white
              .withOpacity(1 - sliderEntryAnimationController.value),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              sliderDetails["imageUrl"],
            ),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              _bgColorList[_currentIndex]
                  .withOpacity(colorOpacityAnimation.value),
              BlendMode.srcOver,
            ),
          ),
        ),
        child: Container(
          color: Colors.white
              .withOpacity(1.0 - sliderEntryAnimationController.value),
        ),
      );
    }
  }

  Widget buildMainPageItems(int currentPage) {
    var mainPageList = List<Widget>();

    mainPageList.add(
      MainMoviesPage(
        key: PageStorageKey("Main_Movies_Page"),
      ),
    );

    mainPageList.add(
      MainTvShowsPage(
        key: PageStorageKey("Main_Tv_Shows_Page"),
      ),
    );

    mainPageList.add(
      MainPersonsPage(
        key: PageStorageKey("Main_Persons_Page"),
      ),
    );

    return mainPageList[currentPage];
  }
}

class TvDataSearch extends SearchDelegate<String> {
  var recentSearch = List<String>();

  TvDataSearch(this.recentSearch);

  var tvShowSearchResults = List<DefaultMainTvShowResultsModel>();

  Future<List<DefaultMainTvShowResultsModel>> getSearchResults(
      String query) async {
    final response = await http.get(
      Uri.encodeFull(
          'https://api.themoviedb.org/3/search/tv?api_key=63e2f7bc00c513994d63c9be541a08d1&query=$query'),
      headers: {
        "Accept": "application/json",
      },
    );

    if (response.statusCode == 200) {
      DefaultMainTvShowModel tvShowResultsModel =
          DefaultMainTvShowModel.fromJson(json.decode(response.body));

      return tvShowResultsModel.results;
    } else {
      return tvShowSearchResults;
    }
  }

  var _colors = List<Color>();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(
          Icons.clear,
        ),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _colors.add(Colors.green);
    _colors.add(Colors.blue);
    _colors.add(Colors.yellow);
    _colors.add(Colors.purple);
    _colors.add(Colors.deepOrange);

    PageStorageBucket bucket = PageStorageBucket();

    return Scaffold(
      body: FutureBuilder<List<DefaultMainTvShowResultsModel>>(
        future: getSearchResults(query),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              color: Colors.white,
              child: Center(
                child: LoadingBarIndicator(
                  numberOfBars: 5,
                  colors: _colors,
                  barSpacing: 5.0,
                  beginTweenValue: 20.0,
                  endTweenValue: 30.0,
                ),
              ),
            );
          } else if (snapshot.data.length == 0) {
            return Center(
              child: Text(
                "No data found for " + query,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          } else {
            return PageStorage(
              bucket: bucket,
              child: ListView.builder(
                key: PageStorageKey("search_results"),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  var searchResults = snapshot.data[index];

                  String name = searchResults.name;
                  String releaseDate = searchResults.first_air_date.toString();

                  String newName = name == null ||
                          name == "" ||
                          name.length <= 0
                      ? ""
                      : name.length > 15 ? name.substring(0, 15) + "..." : name;

                  String formatReleaseDate =
                      releaseDate != null && releaseDate != ""
                          ? releaseDate.replaceAll(
                              RegExp(
                                "-",
                                caseSensitive: false,
                              ),
                              "")
                          : "";

                  var newReleaseDate = "";

                  try {
                    var dateTime = DateTime.parse(
                        releaseDate != null && releaseDate != ""
                            ? formatReleaseDate
                            : "");

                    newReleaseDate = DateFormat.formatDate(dateTime, [
                      DateFormat.dd,
                      " ",
                      DateFormat.M,
                      " ",
                      DateFormat.yyyy
                    ]);
                  } catch (FormatException) {
                    newReleaseDate = releaseDate;
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        NewPageTransition(
                          widget: TvShowDetails(
                            tvShowId: searchResults.id,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: <Widget>[
                        searchResults.backdrop_path == null ||
                                searchResults.backdrop_path == ""
                            ? Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.live_tv,
                                    size: 100,
                                  ),
                                ),
                              )
                            : Container(
                                height: 200,
                                child:
                                    Image.network(searchResults.backdrop_path),
                              ),
                        Container(
                          height: 90,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: CircleSlider(
                                    backgroundColor: Colors.transparent,
                                    backgroundMargin:
                                        EdgeInsets.only(left: 10.0),
                                    backgroundBorderRadius: BorderRadius.all(
                                      Radius.circular(
                                        0.0,
                                      ),
                                    ),
                                    width: 90,
                                    height: 90,
                                    sliderSize: 25.0,
                                    sliderColor: Colors.deepPurple,
                                    sliderPercentage:
                                        searchResults.vote_average * 10,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          newName,
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: "ConcertOne-Regular",
                                            color: Colors.black,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.topLeft,
                                        margin: EdgeInsets.only(
                                          top: 7.0,
                                        ),
                                        child: Text(
                                          newReleaseDate,
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          child: Icon(
                                            Icons.favorite,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                            left: 5.0,
                                            right: 5.0,
                                            bottom: 5.0,
                                          ),
                                          child: Text(
                                            searchResults.vote_count != null
                                                ? searchResults.vote_count
                                                    .toString()
                                                : "0",
                                            style: TextStyle(
                                              fontFamily: "ConcertOne-Regular",
                                              color: Colors.black,
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
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (recentSearch != null && recentSearch.length > 0) {
      return ListView.builder(
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              query = recentSearch[index];
            },
            child: ListTile(
              leading: Icon(Icons.timer),
              title: Text(
                recentSearch[index],
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
        itemCount: recentSearch.length,
      );
    } else {
      return Container(
        margin: EdgeInsets.all(15.0),
        child: Text(
          "No recent searches",
          style: TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
  }
}
