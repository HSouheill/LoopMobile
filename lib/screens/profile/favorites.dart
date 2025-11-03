import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../models/favorite.dart';
import '../../services/favorite_service.dart';
import '../../widgets/favorite_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Favorite> favorites = [];
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  int currentPage = 1;
  int totalPages = 1;
  int totalCount = 0;
  bool hasNextPage = false;
  bool hasPrevPage = false;
  final int itemsPerPage = 8;
  bool isLoadingMore = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadFavorites();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (hasNextPage && !isLoading && !isLoadingMore) {
        _loadNextPage();
      }
    }
  }

  Future<void> _loadFavorites({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        currentPage = 1;
        favorites.clear();
      });
    }

    setState(() {
      if (isRefresh || currentPage == 1) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
      hasError = false;
    });

    try {
      final result = await FavoriteService.getUserFavorites(
        page: currentPage,
        limit: itemsPerPage,
      );

      if (result['success'] == true && result['data'] != null) {
        final FavoritesResponse response = result['data'];
        setState(() {
          if (isRefresh || currentPage == 1) {
            // Replace the favorites list for refresh or first page
            favorites = response.favorites;
          } else {
            // Append new favorites for pagination
            favorites.addAll(response.favorites);
          }
          totalPages = response.pagination.totalPages;
          totalCount = response.pagination.totalCount;
          hasNextPage = response.pagination.hasNextPage;
          hasPrevPage = response.pagination.hasPrevPage;
          isLoading = false;
          isLoadingMore = false;
        });
      } else {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          hasError = true;
          errorMessage = result['message'] ?? l10n.failedToLoadFavorites;
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        hasError = true;
        errorMessage = l10n.networkErrorOccurred;
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (hasNextPage && !isLoading && !isLoadingMore) {
      setState(() {
        currentPage++;
      });
      await _loadFavorites(isRefresh: false);
    }
  }

  Future<void> _removeFavorite(Favorite favorite) async {
    try {
      final result = await FavoriteService.removeFavorite(
        favoritedObjectId: favorite.favoritedObjectId,
        table: favorite.table,
      );

      if (result['success'] == true) {
        setState(() {
          favorites.removeWhere((item) => item.id == favorite.id);
          totalCount--;
        });
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.removedFromFavorites),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? l10n.failedToRemoveFavorite),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.networkErrorOccurred),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onFavoriteTap(Favorite favorite) {
    // Handle tap on favorite item
    // You can navigate to the specific item's detail page here
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Tapped on ${favorite.objectDetails.displayTitle}'),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (totalCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  l10n.itemsCount(totalCount),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadFavorites(isRefresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading && favorites.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final l10n = AppLocalizations.of(context)!;
    if (hasError && favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadFavorites(isRefresh: true),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noFavoritesYet,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.favoritesDescription,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
         Expanded(
           child: ListView.builder(
             controller: _scrollController,
             padding: const EdgeInsets.all(8.0),
             itemCount: (favorites.length / 2).ceil() + (isLoadingMore ? 1 : 0),
             itemBuilder: (context, rowIndex) {
               if (rowIndex >= (favorites.length / 2).ceil()) {
                 // Loading indicator for next page
                 return const Center(
                   child: Padding(
                     padding: EdgeInsets.all(16.0),
                     child: CircularProgressIndicator(),
                   ),
                 );
               }

               // Build a row with 2 cards (or 1 if odd number)
               final firstIndex = rowIndex * 2;
               final secondIndex = firstIndex + 1;
               final hasSecondCard = secondIndex < favorites.length;

               return Padding(
                 padding: const EdgeInsets.only(bottom: 8.0),
                 child: Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Expanded(
                       child: Padding(
                         padding: const EdgeInsets.only(right: 4.0),
                         child: FavoriteCard(
                           favorite: favorites[firstIndex],
                           onTap: () => _onFavoriteTap(favorites[firstIndex]),
                           onRemove: () => _removeFavorite(favorites[firstIndex]),
                         ),
                       ),
                     ),
                     Expanded(
                       child: Padding(
                         padding: EdgeInsets.only(left: 4.0),
                         child: hasSecondCard
                             ? FavoriteCard(
                                 favorite: favorites[secondIndex],
                                 onTap: () => _onFavoriteTap(favorites[secondIndex]),
                                 onRemove: () => _removeFavorite(favorites[secondIndex]),
                               )
                             : const SizedBox.shrink(),
                       ),
                     ),
                   ],
                 ),
               );
             },
           ),
         ),
        // Pagination info
        if (totalCount > 0)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    if (isLoadingMore) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text(l10n.loadingMore),
                        ],
                      );
                    } else {
                      return Text(
                        l10n.showingXOfYItems(favorites.length, totalCount),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
