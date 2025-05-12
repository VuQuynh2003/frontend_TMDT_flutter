import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:debt_manager_app/services/product_service.dart';
import '../widgets/action_buttons.dart';
import '../widgets/form_dialog.dart';

class ItemsListPage extends StatefulWidget {
  const ItemsListPage({super.key});

  @override
  State<ItemsListPage> createState() => _ItemsListPageState();
}

class _ItemsListPageState extends State<ItemsListPage> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> filteredProducts = [];
  bool isLoading = true;
  bool _isSelectionMode = false;
  final Set<int> _selectedProducts = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  // Phương thức tải danh sách sản phẩm
  Future<void> _loadProducts() async {
    try {
      final data = await _productService.getProducts();
      setState(() {
        products = data;
        filteredProducts = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: ${e.toString()}')),
      );
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredProducts =
          products
              .where((product) => product['name'].toLowerCase().contains(query))
              .toList();
    });
  }

  // Phương thức xoá các sản phẩm đã chọn
  Future<void> _deleteSelectedProducts() async {
    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No products selected')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Confirm Delete',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 14, 19, 29),
            ),
          ),
          content: Text(
            'Are you sure you want to delete ${_selectedProducts.length} selected products?',
            style: const TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color.fromARGB(255, 16, 80, 98)),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 16, 80, 98),
                        ),
                      );
                    },
                  );

                  final List<String> productIds =
                      _selectedProducts
                          .map((index) => products[index]['id'].toString())
                          .toList();

                  await _productService.deleteMultipleProducts(productIds);
                  Navigator.pop(context);

                  setState(() {
                    final List<int> sortedIndices =
                        _selectedProducts.toList()
                          ..sort((a, b) => b.compareTo(a));

                    for (final index in sortedIndices) {
                      products.removeAt(index);
                    }

                    _selectedProducts.clear();
                    _isSelectionMode = false;
                    _filterProducts();
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Products deleted successfully'),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return FormDialog(
          title: 'Add New Product',
          submitButtonText: 'Add',
          fields: [
            const CustomFormField(
              name: 'name',
              label: 'Product Name',
              hint: 'Enter product name',
              icon: Icons.inventory_2,
            ),
            const CustomFormField(
              name: 'description',
              label: 'Description',
              hint: 'Enter product description',
              icon: Icons.description,
            ),
            CustomFormField(
              name: 'price',
              label: 'Price',
              hint: 'Enter product price',
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
          onCancel: () => Navigator.pop(context),
          onSubmit: (values) async {
            try {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 16, 80, 98),
                    ),
                  );
                },
              );

              final newProduct = await _productService.addProduct(
                values['name']!,
                values['description']!,
                double.parse(values['price']!),
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added successfully')),
              );

              setState(() {
                products.add(newProduct);
                _filterProducts();
              });
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
            }
          },
        );
      },
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return FormDialog(
          title: 'Edit Product',
          submitButtonText: 'Save',
          initialValues: {
            'name': product['name'],
            'description': product['description'] ?? '',
            'price': product['price'].toString(),
          },
          fields: [
            const CustomFormField(
              name: 'name',
              label: 'Product Name',
              hint: 'Enter product name',
              icon: Icons.inventory_2,
            ),
            const CustomFormField(
              name: 'description',
              label: 'Description',
              hint: 'Enter product description',
              icon: Icons.description,
            ),
            CustomFormField(
              name: 'price',
              label: 'Price',
              hint: 'Enter product price',
              icon: Icons.attach_money,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
          onCancel: () => Navigator.pop(context),
          onSubmit: (values) async {
            try {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 16, 80, 98),
                    ),
                  );
                },
              );

              final updatedProduct = {
                ...product,
                'name': values['name'],
                'description': values['description'],
                'price': double.parse(values['price']!),
              };

              await _productService.updateProduct(updatedProduct);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product updated successfully')),
              );

              setState(() {
                products[index] = updatedProduct;
                _filterProducts();
              });
            } catch (e) {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
            }
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 80, 98),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 14, 19, 29),
        title: const Text(
          'Products List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search by name',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child:
                        isLoading
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Color.fromARGB(255, 16, 80, 98),
                              ),
                            )
                            : ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                final originalIndex = products.indexOf(product);

                                return InkWell(
                                  onTap: () {
                                    if (_isSelectionMode) {
                                      setState(() {
                                        if (_selectedProducts.contains(
                                          originalIndex,
                                        )) {
                                          _selectedProducts.remove(
                                            originalIndex,
                                          );
                                        } else {
                                          _selectedProducts.add(originalIndex);
                                        }
                                      });
                                    } else {
                                      Navigator.pushNamed(
                                        context,
                                        '/item_detail',
                                        arguments: product,
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color:
                                            _selectedProducts.contains(
                                                  originalIndex,
                                                )
                                                ? Colors.blue.withOpacity(0.1)
                                                : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.2),
                                            spreadRadius: 2,
                                            blurRadius: 5,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                        border:
                                            _selectedProducts.contains(
                                                  originalIndex,
                                                )
                                                ? Border.all(color: Colors.blue)
                                                : null,
                                      ),
                                      child: Row(
                                        children: [
                                          if (_isSelectionMode)
                                            Checkbox(
                                              value: _selectedProducts.contains(
                                                originalIndex,
                                              ),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedProducts.add(
                                                      originalIndex,
                                                    );
                                                  } else {
                                                    _selectedProducts.remove(
                                                      originalIndex,
                                                    );
                                                  }
                                                });
                                              },
                                              activeColor: const Color.fromARGB(
                                                255,
                                                16,
                                                80,
                                                98,
                                              ),
                                            ),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                255,
                                                16,
                                                80,
                                                98,
                                              ).withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.inventory_2,
                                              color: Color.fromARGB(
                                                255,
                                                16,
                                                80,
                                                98,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product['name'],
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                if (product['description'] !=
                                                    null)
                                                  Text(
                                                    product['description'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Price: ${product['price']}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromARGB(
                                                      255,
                                                      16,
                                                      80,
                                                      98,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (!_isSelectionMode)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                color: Color.fromARGB(
                                                  255,
                                                  16,
                                                  80,
                                                  98,
                                                ),
                                                size: 20,
                                              ),
                                              onPressed:
                                                  () => _showEditProductDialog(
                                                    product,
                                                    originalIndex,
                                                  ),
                                              tooltip: 'Edit Product',
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
            ActionButtons(
              isSelectionMode: _isSelectionMode,
              onDeleteSelected: _deleteSelectedProducts,
              onAdd: _showAddProductDialog,
              onToggleSelection: () {
                setState(() {
                  if (_isSelectionMode) {
                    _isSelectionMode = false;
                    _selectedProducts.clear();
                  } else {
                    _isSelectionMode = true;
                  }
                });
              },
              rightBtnTag: "itemsRightBtn",
              leftBtnTag: "itemsLeftBtn",
            ),
          ],
        ),
      ),
    );
  }
}
