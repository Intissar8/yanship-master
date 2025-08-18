
import 'package:flutter/material.dart';
import 'package:yanship/register_screen.dart';

import 'login_screen.dart';

class SafeExpanded extends StatelessWidget {
  final Widget child;
  final int flex;

  const SafeExpanded({
    super.key,
    required this.child,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    if (isMobile) {
      return child;
    } else {
      return Expanded(flex: flex, child: child);
    }
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      appBar: const CustomNavbar(),
      // Drawer uniquement sur mobile
      endDrawer: isMobile ? const CustomDrawer() : null,
      drawerEnableOpenDragGesture:
      false, // 🔹 Empêche ouverture par swipe qui recrée un hamburger
      body: SingleChildScrollView(
        child: Column(
          children: const [
            HomeSection(),
            Divider(height: 60),
            PickingUpSection(),
            Divider(height: 60),
            WarehousingSection(),
            Divider(height: 60),
            ConfirmationSection(),
            Divider(height: 60),
            ShippingSection(),
            Divider(height: 60),
            PackingSection(),
            Divider(height: 60),
            FeaturesSection(),
            Divider(height: 60),
            VipPlansSection(),
            ContactSection(),
          ],
        ),
      ),
    );
  }
}

class CustomNavbar extends StatelessWidget implements PreferredSizeWidget {
  const CustomNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 4,
      toolbarHeight: 80,
      titleSpacing: 0,
      automaticallyImplyLeading: false, // ✅ Supprime hamburger auto
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/images/logo.png',
                height: 55,
              ),
            ),
            const Spacer(),
            if (!isMobile)
              Row(
                children: [
                  _NavItem(title: "Home", onTap: () {}),
                  const SizedBox(width: 24),
                  _NavItem(
                    title: "Sign in",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 24),
                  _NavItem(
                    title: "Sign Up",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                  ),
                ],
              ),


          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _NavItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF222222),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}



class HomeSection extends StatelessWidget {
  const HomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final leftChild = Column(
      crossAxisAlignment:
      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const Text(
          "Yan Ship offers a\ncomplete delivery pack.",
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            height: 1.4,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          "We are your partner and your extension, picking up your products and warehousing "
              "then confirming your orders, passing through the packing to the shipping.",
          style: TextStyle(
            fontSize: 20,
            height: 1.7,
            color: Color(0xFF4F4F4F),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BDE0),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: const Text(
            "Get Started",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),

      ],
    );

    final rightChild = Image.asset(
      'assets/images/delivery.png',
      height: isMobile ? 280 : 400,
      fit: BoxFit.contain,
    );

    final left = isMobile ? leftChild : SafeExpanded(flex: 1, child: leftChild);
    final right = isMobile ? rightChild : SafeExpanded(flex: 1, child: rightChild);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 50),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        children: [
          left,
          const SizedBox(width: 40, height: 40),
          right,
        ],
      ),
    );
  }
}

class PickingUpSection extends StatelessWidget {
  const PickingUpSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final leftChild = Column(
      crossAxisAlignment:
      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: const [
        Text(
          "Picking up",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Color(0xFF222222),
          ),
        ),
        SizedBox(height: 25),
        Text(
          "We buy products on your behalf from the supplier or we go pick up "
              "your products from your door — door-to-door service without any additional fees.",
          style: TextStyle(
            fontSize: 20,
            height: 1.7,
            color: Color(0xFF4F4F4F),
          ),
        ),
      ],
    );

    final rightChild = Image.asset(
      'assets/images/pickup.png',
      height: isMobile ? 280 : 400,
      fit: BoxFit.contain,
    );

    final left = isMobile ? leftChild : SafeExpanded(flex: 1, child: leftChild);
    final right = isMobile ? rightChild : SafeExpanded(flex: 1, child: rightChild);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 50),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        children: [
          left,
          const SizedBox(width: 40, height: 40),
          right,
        ],
      ),
    );
  }
}

class WarehousingSection extends StatelessWidget {
  const WarehousingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final leftChild = Image.asset(
      'assets/images/warehouse.png',
      height: isMobile ? 280 : 400,
      fit: BoxFit.contain,
    );

    final rightChild = Column(
      crossAxisAlignment:
      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: const [
        Text(
          "Warehousing",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Color(0xFF222222),
          ),
        ),
        SizedBox(height: 25),
        Text(
          "We store your goods in our warehouse without additional fees and this is a good strategy "
              "to optimize delivery time and control your stock easily and quickly.",
          style: TextStyle(
            fontSize: 20,
            height: 1.7,
            color: Color(0xFF4F4F4F),
          ),
        ),
      ],
    );

    final left = isMobile ? leftChild : SafeExpanded(flex: 1, child: leftChild);
    final right = isMobile ? rightChild : SafeExpanded(flex: 1, child: rightChild);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 50),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        children: [
          left,
          const SizedBox(width: 40, height: 40),
          right,
        ],
      ),
    );
  }
}

class ConfirmationSection extends StatelessWidget {
  const ConfirmationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final leftChild = Image.asset(
      'assets/images/confirmation.png',
      height: isMobile ? 280 : 400,
      fit: BoxFit.contain,
    );

    final rightChild = Column(
      crossAxisAlignment:
      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: const [
        Text(
          "Confirmation",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Color(0xFF222222),
          ),
        ),
        SizedBox(height: 25),
        Text(
          "We suggest you our call center service to let you focus more on the marketing and scale your business.",
          style: TextStyle(
            fontSize: 20,
            height: 1.7,
            color: Color(0xFF4F4F4F),
          ),
        ),
      ],
    );

    final left = isMobile ? leftChild : SafeExpanded(flex: 1, child: leftChild);
    final right = isMobile ? rightChild : SafeExpanded(flex: 1, child: rightChild);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 50),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        children: [
          left,
          const SizedBox(width: 40, height: 40),
          right,
        ],
      ),
    );
  }
}

class ShippingSection extends StatelessWidget {
  const ShippingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final leftChild = Column(
      crossAxisAlignment:
      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: const [
        Text(
          "Shipping",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Color(0xFF222222),
          ),
        ),
        SizedBox(height: 25),
        Text(
          "And this is what the goal we are here shipping sometimes less than 3h and average 24h to any city and region in Morocco.",
          style: TextStyle(
            fontSize: 20,
            height: 1.7,
            color: Color(0xFF4F4F4F),
          ),
        ),
      ],
    );

    final rightChild = Image.asset(
      'assets/images/shipping.png',
      height: isMobile ? 280 : 400,
      fit: BoxFit.contain,
    );

    final left = isMobile ? leftChild : SafeExpanded(flex: 1, child: leftChild);
    final right = isMobile ? rightChild : SafeExpanded(flex: 1, child: rightChild);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 50),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        children: [
          left,
          const SizedBox(width: 40, height: 40),
          right,
        ],
      ),
    );
  }
}

class PackingSection extends StatelessWidget {
  const PackingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final leftChild = Image.asset(
      'assets/images/packing.png',
      height: isMobile ? 280 : 400,
      fit: BoxFit.contain,
    );

    final rightChild = Column(
      crossAxisAlignment:
      isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: const [
        Text(
          "Packing",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.3,
            color: Color(0xFF222222),
          ),
        ),
        SizedBox(height: 25),
        Text(
          "We know sometimes you don't have time to packing your products or you need to spend this time on another part of business, so we offer you this service to go further both of us.",
          style: TextStyle(
            fontSize: 20,
            height: 1.7,
            color: Color(0xFF4F4F4F),
          ),
        ),
      ],
    );

    final left = isMobile ? leftChild : SafeExpanded(flex: 1, child: leftChild);
    final right = isMobile ? rightChild : SafeExpanded(flex: 1, child: rightChild);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 50),
      child: Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        children: [
          left,
          const SizedBox(width: 40, height: 40),
          right,
        ],
      ),
    );
  }
}

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final features = const [
      FeatureCard(
        icon: Icons.settings,
        title: "We offer all in one pack",
        description:
        "No need to distracting between a lot of services we give you a complete pack. Just scale it.!",
      ),
      FeatureCard(
        icon: Icons.local_shipping,
        title: "Fast shipping",
        description:
        "Our delivery time to all morocco with an average time of 24H. Yalla.!",
      ),
      FeatureCard(
        icon: Icons.attach_money,
        title: "24H payment",
        description:
        "We send payments daily so there is no late cash flow. Money ringtone.!",
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 50),
      child: Column(
        children: [
          const Text(
            "From supplier or picking up from your door to delivered and money back to you in 24H.",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: Color(0xFF222222),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // ✅ If mobile → horizontal scroll, else Wrap
          if (isMobile)
            SizedBox(
              height: 320,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: features.length,
                separatorBuilder: (_, __) => const SizedBox(width: 20),
                itemBuilder: (context, index) => features[index],
              ),
            )
          else
            Wrap(
              spacing: 40,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              children: features,
            ),
        ],
      ),
    );
  }
}


class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Icon(icon, size: 48, color: Color(0xFF00BDE0)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF4F4F4F),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class VipPlansSection extends StatelessWidget {
  const VipPlansSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final plans = const [
      VipPlanCard(
        title: "Silver",
        price: "10",
        orders: "50 ORDERS DELIVERED OR LESS / PER MONTH",
        imageAsset: 'assets/images/silver.png',
      ),
      VipPlanCard(
        title: "Gold",
        price: "9",
        orders: "+50 ORDERS / PER MONTH",
        imageAsset: 'assets/images/gold.png',
      ),
      VipPlanCard(
        title: "Platinum",
        price: "7",
        orders: "+100 ORDERS / PER MONTH",
        imageAsset: 'assets/images/platinum.png',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 50),
      child: Column(
        children: [
          const Text(
            "VIP plans",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "Optionally for sellers\nCover all the country with average delivery time of 3h.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              height: 1.6,
              color: Color(0xFF4F4F4F),
            ),
          ),
          const SizedBox(height: 40),

          // ✅ Mobile → PageView with enough height
          if (isMobile)
            SizedBox(
              height: 520, // enough space for the whole card (no overflow)
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: plans.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: plans[index],
                ),
              ),
            )
          else
            Wrap(
              spacing: 30,
              runSpacing: 30,
              alignment: WrapAlignment.center,
              children: plans,
            ),
        ],
      ),
    );
  }
}




class VipPlanCard extends StatefulWidget {
  final String title;
  final String price;
  final String orders;
  final String imageAsset;

  const VipPlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.orders,
    required this.imageAsset,
  });

  @override
  State<VipPlanCard> createState() => _VipPlanCardState();
}

class _VipPlanCardState extends State<VipPlanCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 280, // taille uniforme
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: _isHovered ? 20 : 12,
              color: Colors.black12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(widget.imageAsset, height: 120),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "${widget.price} MAD/Order",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.orders,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF4F4F4F),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Supplier\nWarehousing\nConfirmation\nPacking",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Color(0xFF4F4F4F),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BDE0),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String email = '';
  String message = '';

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print('Nom: $name');
      print('Email: $email');
      print('Message: $message');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully!')),
      );

      // Logique d’envoi ici (email, backend, etc.)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🟦 Le trait collé directement à la section
        const Divider(height: 0, thickness: 1, color: Colors.grey),
        Container(
          width: double.infinity,
          color: Colors.grey[100],
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "You're welcome to join us\nYan Ship in your service: +212 661 421 738.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? 'Please enter your name' : null,
                          onChanged: (val) => name = val,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? 'Please enter your email' : null,
                          onChanged: (val) => email = val,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Message',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 5,
                          validator: (value) => value!.isEmpty
                              ? 'Please enter a message'
                              : null,
                          onChanged: (val) => message = val,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blueAccent,
                            ),
                            onPressed: _submitForm,
                            child: const Text(
                              'Send Now!',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text("Sign In"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text("Sign Up"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
          ),

        ],
      ),
    );
  }
}
