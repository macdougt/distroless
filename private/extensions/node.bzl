"node"

BUILD_TMPL = """\
# GENERATED BY node_archive.bzl
load("@distroless//private/pkg:debian_spdx.bzl", "debian_spdx")
load("@distroless//private/util:merge_providers.bzl", "merge_providers")
load("@rules_pkg//:pkg.bzl", "pkg_tar")

pkg_tar(
    name = "data",
    srcs = glob(
        [
            "output/bin/node",
            "output/LICENSE",
        ],
    ),
    package_dir = "/nodejs",
    strip_prefix = "external/{canonical_name}/output"
)

pkg_tar(
    name = "_control",
    srcs = ["control"]
)

debian_spdx(
    name = "spdx",
    control = ":_control.tar",
    data = ":data.tar",
    package_name = "{package_name}",
    spdx_id = "{spdx_id}",
    sha256 = "{sha256}",
    urls = [{urls}]
)

merge_providers(
    name = "{name}",
    srcs = [":data", ":spdx"],
    visibility = ["//visibility:public"],
)
"""

def _impl(rctx):
    rctx.report_progress("Fetching {}".format(rctx.attr.package_name))
    rctx.download_and_extract(
        url = rctx.attr.urls,
        sha256 = rctx.attr.sha256,
        type = rctx.attr.type,
        stripPrefix = rctx.attr.strip_prefix,
        output = "output",
    )
    rctx.template(
        "control",
        rctx.attr.control,
        substitutions = {
            "{{VERSION}}": rctx.attr.version,
            "{{ARCHITECTURE}}": rctx.attr.architecture,
            "{{SHA256}}": rctx.attr.sha256,
        },
    )
    rctx.file(
        "BUILD.bazel",
        content = BUILD_TMPL.format(
            canonical_name = rctx.attr.name,
            name = rctx.attr.name.split("~")[-1],
            package_name = rctx.attr.package_name,
            spdx_id = rctx.attr.name,
            urls = ",".join(['"%s"' % url for url in rctx.attr.urls]),
            sha256 = rctx.attr.sha256,
        ),
    )

node_archive = repository_rule(
    implementation = _impl,
    attrs = {
        "urls": attr.string_list(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "type": attr.string(default = ".tar.gz"),
        "strip_prefix": attr.string(),
        "package_name": attr.string(default = "nodejs"),
        "version": attr.string(mandatory = True),
        "architecture": attr.string(mandatory = True),
        # control is only used to populate the sbom, see https://github.com/GoogleContainerTools/distroless/issues/1373
        # for why writing debian control files to the image is incompatible with scanners.
        "control": attr.label(),
    },
)

def _node_impl(module_ctx):
    mod = module_ctx.modules[0]

    if len(module_ctx.modules) > 1:
        fail("node.archive should be called only once")
    if not mod.is_root:
        fail("node.archive should be called from root module only.")

    # Node (https://nodejs.org/en/about/releases/)
    # Follow Node's maintainence schedule and support all LTS versions that are not end of life

    node_archive(
        name = "nodejs18_amd64",
        sha256 = "e7b80346bb586790ac6b29aa25c96716fcdf6039a6929c2ed506cec09cebc3c0",
        strip_prefix = "node-v18.20.5-linux-x64/",
        urls = ["https://nodejs.org/dist/v18.20.5/node-v18.20.5-linux-x64.tar.gz"],
        version = "18.20.5",
        architecture = "amd64",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs18_arm64",
        sha256 = "759cfb9f76a1019daf65db9c2e5e43074ee660ec9b9ff3f31dcc4a88cca671e9",
        strip_prefix = "node-v18.20.5-linux-arm64/",
        urls = ["https://nodejs.org/dist/v18.20.5/node-v18.20.5-linux-arm64.tar.gz"],
        version = "18.20.5",
        architecture = "arm64",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs18_arm",
        sha256 = "8d358452e4fcf34b0dcf51a441ec8cf192f8ff83bdd4488708dcab18e8007621",
        strip_prefix = "node-v18.20.5-linux-armv7l/",
        urls = ["https://nodejs.org/dist/v18.20.5/node-v18.20.5-linux-armv7l.tar.gz"],
        version = "18.20.5",
        architecture = "arm",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs18_ppc64le",
        sha256 = "1f916c66f96d9265394e3145bfa92be918abbb45ac9711a441cce99d76618f4a",
        strip_prefix = "node-v18.20.5-linux-ppc64le/",
        urls = ["https://nodejs.org/dist/v18.20.5/node-v18.20.5-linux-ppc64le.tar.gz"],
        version = "18.20.5",
        architecture = "ppc64le",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs18_s390x",
        sha256 = "e9ca8239a1256ff66ecd156bf42e88eaad7a1276c421c1c5fd0d6936dcc59300",
        strip_prefix = "node-v18.20.5-linux-s390x/",
        urls = ["https://nodejs.org/dist/v18.20.5/node-v18.20.5-linux-s390x.tar.gz"],
        version = "18.20.5",
        architecture = "s390x",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs20_amd64",
        sha256 = "259e5a8bf2e15ecece65bd2a47153262eda71c0b2c9700d5e703ce4951572784",
        strip_prefix = "node-v20.18.1-linux-x64/",
        urls = ["https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-x64.tar.gz"],
        version = "20.18.1",
        architecture = "amd64",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs20_arm64",
        sha256 = "73cd297378572e0bc9dfc187c5ec8cca8d43aee6a596c10ebea1ed5f9ec682b6",
        strip_prefix = "node-v20.18.1-linux-arm64/",
        urls = ["https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-arm64.tar.gz"],
        version = "20.18.1",
        architecture = "arm64",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs20_arm",
        sha256 = "7b7c3315818e9fe57512737c2380fada14d8717ce88945fb6f7b8baadd3cfb92",
        strip_prefix = "node-v20.18.1-linux-armv7l/",
        urls = ["https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-armv7l.tar.gz"],
        version = "20.18.1",
        architecture = "arm",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs20_ppc64le",
        sha256 = "703fc140e330002020bf54cffcfbbf8a957413b23fe6940a9f5a147e5103e960",
        strip_prefix = "node-v20.18.1-linux-ppc64le/",
        urls = ["https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-ppc64le.tar.gz"],
        version = "20.18.1",
        architecture = "ppc64le",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs20_s390x",
        sha256 = "15724744d75fa10f5856b17d5293d141175a2832b7c17bf12df669d4b22b12bc",
        strip_prefix = "node-v20.18.1-linux-s390x/",
        urls = ["https://nodejs.org/dist/v20.18.1/node-v20.18.1-linux-s390x.tar.gz"],
        version = "20.18.1",
        architecture = "s390x",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs22_amd64",
        sha256 = "4f862bab52039835efbe613b532238b6e4dde98d139a34e6923193e073438b13",
        strip_prefix = "node-v22.11.0-linux-x64/",
        urls = ["https://nodejs.org/dist/v22.11.0/node-v22.11.0-linux-x64.tar.gz"],
        version = "22.11.0",
        architecture = "amd64",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs22_arm64",
        sha256 = "27453f7a0dd6b9e6738f1f6ea6a09b102ec7aa484de1e39d6a1c3608ad47aa6a",
        strip_prefix = "node-v22.11.0-linux-arm64/",
        urls = ["https://nodejs.org/dist/v22.11.0/node-v22.11.0-linux-arm64.tar.gz"],
        version = "22.11.0",
        architecture = "arm64",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs22_arm",
        sha256 = "f85ced095b17e2535859fd2a5641370c3fca12dd72147f93d2696e2909fe1e9d",
        strip_prefix = "node-v22.11.0-linux-armv7l/",
        urls = ["https://nodejs.org/dist/v22.11.0/node-v22.11.0-linux-armv7l.tar.gz"],
        version = "22.11.0",
        architecture = "arm",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs22_ppc64le",
        sha256 = "0532965a717d3996302a111703c007dac2763e01795730d488dadbc2fcfac2fa",
        strip_prefix = "node-v22.11.0-linux-ppc64le/",
        urls = ["https://nodejs.org/dist/v22.11.0/node-v22.11.0-linux-ppc64le.tar.gz"],
        version = "22.11.0",
        architecture = "ppc64le",
        control = "//nodejs:control",
    )

    node_archive(
        name = "nodejs22_s390x",
        sha256 = "64f691400ffe3a84be930e0cb03607d0b95bef122a679f7893d8e2972e90c521",
        strip_prefix = "node-v22.11.0-linux-s390x/",
        urls = ["https://nodejs.org/dist/v22.11.0/node-v22.11.0-linux-s390x.tar.gz"],
        version = "22.11.0",
        architecture = "s390x",
        control = "//nodejs:control",
    )

    return module_ctx.extension_metadata(
        root_module_direct_deps = [
            "nodejs18_amd64",
            "nodejs18_arm64",
            "nodejs18_arm",
            "nodejs18_ppc64le",
            "nodejs18_s390x",
            "nodejs20_amd64",
            "nodejs20_arm64",
            "nodejs20_arm",
            "nodejs20_ppc64le",
            "nodejs20_s390x",
            "nodejs22_amd64",
            "nodejs22_arm64",
            "nodejs22_arm",
            "nodejs22_ppc64le",
            "nodejs22_s390x",
        ],
        root_module_direct_dev_deps = [],
    )

_archive = tag_class(attrs = {})

node = module_extension(
    implementation = _node_impl,
    tag_classes = {
        "archive": _archive,
    },
)
