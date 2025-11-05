enum ShopCategory { avatar, background }

ShopCategory shopCategoryFromString(String s) =>
    s.toLowerCase() == 'avatar' ? ShopCategory.avatar : ShopCategory.background;