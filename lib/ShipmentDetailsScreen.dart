import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShipmentDetailsScreen extends StatelessWidget {
  final String shipmentId;
  final Map<String, dynamic> shipmentData;

  const ShipmentDetailsScreen({
    super.key,
    required this.shipmentId,
    required this.shipmentData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shipment Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tracking ID: $shipmentId", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Receiver: ${shipmentData['receiverName'] ?? ''}"),
            Text("Phone: ${shipmentData['receiverPhone'] ?? ''}"),
            Text("City: ${shipmentData['city'] ?? ''}"),
            Text("Price: MAD ${shipmentData['price'] ?? ''}"),
            const SizedBox(height: 20),
            const Divider(),
            const Text("Status History", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('shipments')
                    .doc(shipmentId)
                    .collection('statusHistory')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Text("No history found");
                  }
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return ListTile(
                        leading: const Icon(Icons.local_shipping, color: Colors.blue),
                        title: Text(data['status'] ?? ''),
                        subtitle: Text((data['timestamp'] as Timestamp)
                            .toDate()
                            .toString()),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}