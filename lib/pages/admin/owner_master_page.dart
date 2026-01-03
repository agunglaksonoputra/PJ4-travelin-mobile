import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../models/owner/owner_model.dart';
import '../../services/owner/owner_service.dart';
import '../../widgets/custom_flushbar.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/vehicle_detail_row.dart';

class OwnerMasterPage extends StatefulWidget {
  const OwnerMasterPage({super.key});

  @override
  State<OwnerMasterPage> createState() => _OwnerMasterPageState();
}

class _OwnerMasterPageState extends State<OwnerMasterPage> {
  List<OwnerModel> _owners = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOwners();
  }

  Future<void> _loadOwners() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await OwnerService.getAllOwners();
      if (!mounted) return;

      setState(() {
        _owners = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Owner Management",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorState()
            : _owners.isEmpty
            ? _buildEmptyState()
            : RefreshIndicator(
          onRefresh: _loadOwners,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
            children:
            _owners.map(_buildOwnerCard).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerCard(OwnerModel owner) {
    return Card(
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () => _showOwnerDetail(owner),
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(FontAwesomeIcons.userTie, color: Colors.white, size: 16),
        ),
        title: Text(
          owner.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("Share: ${owner.shareLabel}"),
        trailing: const Icon(FontAwesomeIcons.angleRight, size: 18),
      ),
    );
  }

  // =============================
  // OWNER DETAIL BOTTOM MODAL
  // =============================
  void _showOwnerDetail(OwnerModel owner) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detail Owner",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              VehicleDetailRow(label: "Name", value: owner.name),
              VehicleDetailRow(
                label: "Phone",
                value: owner.phone ?? "-",
              ),
              VehicleDetailRow(
                label: "Shares",
                value: owner.shareLabel,
              ),
              VehicleDetailRow(
                label: "Notes",
                value: owner.notes ?? "-",
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showUpdateOwnerModal(owner);
                      },
                      icon: const Icon(
                        FontAwesomeIcons.pencil,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        "Edit",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  // const SizedBox(width: 12),
                  // Expanded(
                  //   child: ElevatedButton.icon(
                  //     onPressed: () {
                  //       // Navigator.pop(context);
                  //       // _showUpdateOwnerModal(owner);
                  //     },
                  //     icon: const Icon(
                  //       FontAwesomeIcons.trashCan,
                  //       color: Colors.white,
                  //       size: 16,
                  //     ),
                  //     label: const Text(
                  //       "Delete",
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.red,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUpdateOwnerModal(OwnerModel owner) {
    final nameController = TextEditingController(text: owner.name);
    final phoneController = TextEditingController(text: owner.phone ?? "");
    final notesController = TextEditingController(text: owner.notes ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  "Edit Owner",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                /// NAME
                CustomInputField(
                  label: "Nama Owner",
                  icon: FontAwesomeIcons.user,
                  hint: "Nama owner",
                  controller: nameController,
                ),
                const SizedBox(height: 12),

                /// PHONE
                CustomInputField(
                  label: "No. Telepon",
                  icon: FontAwesomeIcons.phone,
                  hint: "08xxxxxxxxxx",
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                /// NOTES
                CustomInputField(
                  label: "Catatan",
                  icon: FontAwesomeIcons.noteSticky,
                  hint: "-",
                  controller: notesController,
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    /// CANCEL
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    /// UPDATE
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final payload = {
                            "name": nameController.text.trim(),
                            "phone": phoneController.text.trim().isEmpty
                                ? null
                                : phoneController.text.trim(),
                            "notes": notesController.text.trim().isEmpty
                                ? null
                                : notesController.text.trim(),
                          };

                          try {
                            final updatedOwner =
                            await OwnerService.updateOwner(
                              owner.id,
                              payload,
                            );

                            if (!mounted) return;

                            setState(() {
                              final index = _owners.indexWhere((o) => o.id == owner.id);
                              if (index != -1) {
                                _owners[index] = updatedOwner;
                              }
                            });

                            Navigator.pop(context);

                            CustomFlushbar.show(
                              context,
                              message: "Owner berhasil diperbarui",
                              type: FlushbarType.success,
                            );
                          } catch (e) {
                            Navigator.pop(context);
                            CustomFlushbar.show(
                              context,
                              message: e.toString(),
                              type: FlushbarType.error,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =============================
  // STATES
  // =============================
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(FontAwesomeIcons.circleExclamation, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text("Error loading owners"),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadOwners,
            child: const Text("Try Again"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(FontAwesomeIcons.users, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text("No owners found"),
        ],
      ),
    );
  }
}