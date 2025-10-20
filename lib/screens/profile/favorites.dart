import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadFavorites();
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
        setState(() {
          hasError = true;
          errorMessage = result['message'] ?? 'Failed to load favorites';
          isLoading = false;
          isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Network error occurred';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to remove favorite'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onFavoriteTap(Favorite favorite) {
    // Handle tap on favorite item
    // You can navigate to the specific item's detail page here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped on ${favorite.objectDetails.displayTitle}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: Colors.blue,
        actions: [
          if (totalCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '$totalCount items',
                  style: const TextStyle(fontSize: 14),
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
              child: const Text('Retry'),
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
              'No favorites yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Items you favorite will appear here',
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
          child: GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: favorites.length + (hasNextPage ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == favorites.length) {
                // Loading indicator for next page
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: isLoadingMore
                        ? const CircularProgressIndicator()
                        : TextButton(
                            onPressed: _loadNextPage,
                            child: const Text('Load More'),
                          ),
                  ),
                );
              }

              final favorite = favorites[index];
              return FavoriteCard(
                favorite: favorite,
                onTap: () => _onFavoriteTap(favorite),
                onRemove: () => _removeFavorite(favorite),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${favorites.length} of $totalCount items',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                if (hasNextPage)
                  TextButton(
                    onPressed: isLoadingMore ? null : _loadNextPage,
                    child: isLoadingMore
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Load More'),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
