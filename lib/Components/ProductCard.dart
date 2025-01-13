import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final dynamic item;
  final String imageUrl;
  final Function(dynamic) openPopPup;

  const ProductCard({
    required this.item,
    required this.imageUrl,
    required this.openPopPup,
    Key? key,
  }) : super(key: key);

  String getDate(String? dateStr) {
    // Format date as needed, return a formatted date string
    return dateStr ?? 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              item?.sku ?? '',
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontSize: 18,
                fontFamily: 'PoppinsMedium',
              ),
            ),
          ),
          GestureDetector(
            onTap: () => openPopPup(item),
            child: Image.network(
              '$imageUrl${item?.imagename ?? ''}',
              width: 130,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
          const Divider(
            color: Color(0xFF4C5564),
            thickness: 1,
            height: 5,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Order Date: ${getDate(item?.orderdate)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4C5564),
                    fontSize: 10,
                    fontFamily: 'PoppinsMedium',
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 35,
                color: const Color(0xFF4C5564),
              ),
              Expanded(
                child: Text(
                  'Delivery Date: ${getDate(item?.deldate)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4C5564),
                    fontSize: 10,
                    fontFamily: 'PoppinsMedium',
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            color: Color(0xFF4C5564),
            thickness: 1,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  item?.process ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4C5564),
                    fontSize: 10,
                    fontFamily: 'PoppinsMedium',
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 25,
                color: const Color(0xFF4C5564),
              ),
              Expanded(
                child: OrderDeliveryComponent(
                  orderDateStr: item?.orderdate,
                  deliveryDateStr: item?.deldate,
                ),
              ),
            ],
          ),
          const Divider(
            color: Color(0xFF4C5564),
            thickness: 1,
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  item?.item ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4C5564),
                    fontSize: 10,
                    fontFamily: 'PoppinsMedium',
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 35,
                color: const Color(0xFF4C5564),
              ),
              Expanded(
                child: Text(
                  item?.metal ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF4C5564),
                    fontSize: 10,
                    fontFamily: 'PoppinsMedium',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OrderDeliveryComponent extends StatelessWidget {
  final String? orderDateStr;
  final String? deliveryDateStr;

  const OrderDeliveryComponent({
    Key? key,
    this.orderDateStr,
    this.deliveryDateStr,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Add your custom implementation here
    return Text(
      'Custom Widget',
      style: const TextStyle(
        color: Color(0xFF4C5564),
        fontSize: 10,
        fontFamily: 'PoppinsMedium',
      ),
    );
  }
}
