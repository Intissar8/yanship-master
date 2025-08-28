import 'package:flutter/material.dart';

class ShipmentsTablePage extends StatelessWidget {
  const ShipmentsTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Shipments",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.lightBlue[100], // 🔵 Light blue app bar
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔎 Modern Filter Row
            Row(
              children: [
                _buildSearchBox("Tracking ID", width: 150),
                const SizedBox(width: 8),
                _buildSearchBox("Search tracking",
                    icon: Icons.search, width: 200),
                const SizedBox(width: 8),
                _buildDropdown(
                  hint: "-- Select shipping status --",
                  items: {
                    "Delivered": Icons.check_circle,
                    "Picked up": Icons.handshake,
                    "No Answer": Icons.call_missed,
                    "Reported": Icons.report,
                    "Rejected": Icons.block,
                    "Cancelled": Icons.cancel,
                  },
                ),
                const Spacer(),
                _buildDropdown(
                  hint: "Filter By",
                  items: {
                    "Date": Icons.calendar_today,
                    "Driver": Icons.drive_eta,
                    "City": Icons.location_city,
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 📋 Shipments Table
            Expanded(
              child: Card(
                elevation: 3,
                color: Colors.white, // 🔲 White background
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 48,
                    dataRowHeight: 56,
                    headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                    dataTextStyle: const TextStyle(color: Colors.black87),
                    dividerThickness: 0.6,
                    columns: const [
                      DataColumn(label: Text("Sender")),
                      DataColumn(label: Text("Driver")),
                      DataColumn(label: Text("Receiver")),
                      DataColumn(label: Text("City")),
                      DataColumn(label: Text("Price")),
                      DataColumn(label: Text("Fee")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Actions")),
                    ],
                    rows: [
                      _buildRow(
                        sender: "test",
                        driver: "MarrakechRegion",
                        receiver: "karim",
                        city: "Marrakech",
                        price: "MAD 500",
                        fee: "-",
                        status: "Delivered",
                        statusColor: Colors.green,
                      ),
                      _buildRow(
                        sender: "test",
                        driver: "demodriver",
                        receiver: "test",
                        city: "Afourar",
                        price: "MAD 12",
                        fee: "-",
                        status: "Picked up",
                        statusColor: Colors.lightBlue, // 🔵 Light blue
                      ),
                      _buildRow(
                        sender: "test",
                        driver: "MarrakechRegion",
                        receiver: "dsf",
                        city: "Ait Ishak",
                        price: "MAD 2222",
                        fee: "-",
                        status: "Reported",
                        statusColor: Colors.orange,
                      ),
                      _buildRow(
                        sender: "test",
                        driver: "CasablancaRegion",
                        receiver: "test",
                        city: "Agadir",
                        price: "MAD 1222",
                        fee: "-",
                        status: "Cancelled",
                        statusColor: Colors.red, // 🔴 Red
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ✨ Modern Search Box
  Widget _buildSearchBox(String hint, {IconData? icon, double? width}) {
    return SizedBox(
      width: width,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black54),
          prefixIcon: icon != null
              ? Icon(icon, size: 20, color: Colors.lightBlue)
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.lightBlue.shade100)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  // ✨ Modern Dropdown
  Widget _buildDropdown({
    required String hint,
    required Map<String, IconData> items,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.lightBlue.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(
            hint,
            style: const TextStyle(color: Colors.black54),
          ),
          items: items.entries
              .map((e) => DropdownMenuItem(
            value: e.key,
            child: Row(
              children: [
                Icon(e.value,
                    size: 18, color: Colors.lightBlue.shade700),
                const SizedBox(width: 8),
                Text(
                  e.key,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ))
              .toList(),
          onChanged: (val) {},
        ),
      ),
    );
  }

  // 🟩 Row builder (without check icon)
  DataRow _buildRow({
    required String sender,
    required String driver,
    required String receiver,
    required String city,
    required String price,
    required String fee,
    required String status,
    required Color statusColor,
  }) {
    return DataRow(
      cells: [
        DataCell(Text(sender)),
        DataCell(Text(driver)),
        DataCell(Text(receiver)),
        DataCell(Text(city)),
        DataCell(Text(price)),
        DataCell(Text(fee)),
        DataCell(Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
        )),
        DataCell(
          PopupMenuButton<String>(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            icon: const Icon(Icons.more_vert, color: Colors.black),
            itemBuilder: (context) => [
              _menuItem("Delivered", Icons.check_circle, Colors.green),
              _menuItem("Picked up", Icons.handshake, Colors.lightBlue),
              _menuItem("No Answer", Icons.call_missed, Colors.orange),
              _menuItem("Reported", Icons.report, Colors.amber),
              _menuItem("Rejected", Icons.block, Colors.redAccent),
              _menuItem("Cancelled", Icons.cancel, Colors.red),
              const PopupMenuDivider(),
              _menuItem("Driver Paid", Icons.account_balance_wallet,
                  Colors.teal),
              _menuItem("Customer Paid", Icons.payment, Colors.indigo),
              _menuItem("Driver Not Paid", Icons.warning, Colors.orange),
              _menuItem("Customer Not Paid", Icons.error, Colors.red),
              const PopupMenuDivider(),
              _menuItem("Edit Shipment", Icons.edit, Colors.black87),
              _menuItem("Print Label", Icons.print, Colors.black87),
              _menuItem("Send Mail", Icons.mail, Colors.black87),
            ],
            onSelected: (value) {
              // TODO: handle actions
            },
          ),
        ),
      ],
    );
  }

  // ✨ Menu item with icon
  PopupMenuItem<String> _menuItem(String text, IconData icon, Color color) {
    return PopupMenuItem(
      value: text,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}
